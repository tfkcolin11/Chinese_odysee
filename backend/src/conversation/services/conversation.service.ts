import { Injectable, NotFoundException, BadRequestException, PaymentRequiredException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Conversation } from '../entities/conversation.entity';
import { ConversationTurn, Speaker, InputMode } from '../entities/conversation-turn.entity';
import { User } from '../../user/entities/user.entity';
import { Scenario } from '../../content/entities/scenario.entity';
import { HskLevel } from '../../content/entities/hsk-level.entity';
import { StartConversationDto } from '../dto/start-conversation.dto';
import { SubmitUserTurnDto } from '../dto/submit-user-turn.dto';
import { SaveConversationDto } from '../dto/save-conversation.dto';
import { AiService } from './ai.service';

@Injectable()
export class ConversationService {
  constructor(
    @InjectRepository(Conversation)
    private conversationRepository: Repository<Conversation>,
    @InjectRepository(ConversationTurn)
    private conversationTurnRepository: Repository<ConversationTurn>,
    @InjectRepository(Scenario)
    private scenarioRepository: Repository<Scenario>,
    @InjectRepository(HskLevel)
    private hskLevelRepository: Repository<HskLevel>,
    private aiService: AiService,
    private configService: ConfigService,
  ) {}

  async startConversation(startConversationDto: StartConversationDto, user: User): Promise<{ conversation: Conversation; initialTurn: ConversationTurn }> {
    // Check if user has reached their daily conversation limit
    if (user.settings?.subscriptionTier !== 'premium') {
      const dailyLimit = this.configService.get<number>('FREE_TIER_DAILY_CONVERSATION_LIMIT', 5);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const conversationsToday = await this.conversationRepository.count({
        where: {
          userId: user.userId,
          createdAt: today,
        },
      });
      
      if (conversationsToday >= dailyLimit) {
        throw new PaymentRequiredException(`You have reached your daily limit of ${dailyLimit} conversations. Upgrade to premium for unlimited conversations.`);
      }
    }

    // Validate scenario
    const scenario = await this.scenarioRepository.findOne({
      where: { scenarioId: startConversationDto.scenarioId },
    });
    
    if (!scenario) {
      throw new NotFoundException(`Scenario with ID ${startConversationDto.scenarioId} not found`);
    }

    // Validate HSK level
    const hskLevel = await this.hskLevelRepository.findOne({
      where: { hskLevelId: startConversationDto.hskLevelPlayed },
    });
    
    if (!hskLevel) {
      throw new NotFoundException(`HSK level with ID ${startConversationDto.hskLevelPlayed} not found`);
    }

    // Validate inspiration saved instance if provided
    if (startConversationDto.inspirationSavedInstanceId) {
      const inspirationConversation = await this.conversationRepository.findOne({
        where: {
          conversationId: startConversationDto.inspirationSavedInstanceId,
          isSaved: true,
        },
      });
      
      if (!inspirationConversation) {
        throw new NotFoundException(`Saved conversation with ID ${startConversationDto.inspirationSavedInstanceId} not found`);
      }
    }

    // Create new conversation
    const conversation = this.conversationRepository.create({
      userId: user.userId,
      scenarioId: startConversationDto.scenarioId,
      hskLevelPlayed: startConversationDto.hskLevelPlayed,
      inspirationSavedInstanceId: startConversationDto.inspirationSavedInstanceId,
    });
    
    await this.conversationRepository.save(conversation);

    // Update scenario last used timestamp
    await this.scenarioRepository.update(
      { scenarioId: startConversationDto.scenarioId },
      { lastUsedAt: new Date() },
    );

    // Generate initial AI turn
    const initialTurn = await this.generateInitialAiTurn(conversation, scenario, hskLevel);

    return {
      conversation,
      initialTurn,
    };
  }

  async submitUserTurn(conversationId: string, submitUserTurnDto: SubmitUserTurnDto, user: User): Promise<{ aiTurn: ConversationTurn; updatedConversationScore: number }> {
    // Find the conversation
    const conversation = await this.conversationRepository.findOne({
      where: {
        conversationId,
        userId: user.userId,
      },
    });
    
    if (!conversation) {
      throw new NotFoundException(`Conversation with ID ${conversationId} not found`);
    }

    if (conversation.isCompleted) {
      throw new BadRequestException('This conversation is already completed');
    }

    // Check if user has reached their daily turn limit (for free tier)
    if (user.settings?.subscriptionTier !== 'premium') {
      const dailyTurnLimit = this.configService.get<number>('FREE_TIER_DAILY_TURN_LIMIT', 30);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      const turnsToday = await this.conversationTurnRepository.count({
        where: {
          conversation: {
            userId: user.userId,
            createdAt: today,
          },
          speaker: Speaker.USER,
        },
      });
      
      if (turnsToday >= dailyTurnLimit) {
        throw new PaymentRequiredException(`You have reached your daily limit of ${dailyTurnLimit} conversation turns. Upgrade to premium for unlimited turns.`);
      }
    }

    // Get the latest turn number
    const latestTurn = await this.conversationTurnRepository.findOne({
      where: { conversationId },
      order: { turnNumber: 'DESC' },
    });
    
    const nextTurnNumber = latestTurn ? latestTurn.turnNumber + 1 : 1;

    // Create user turn
    const userTurn = this.conversationTurnRepository.create({
      conversationId,
      turnNumber: nextTurnNumber,
      speaker: Speaker.USER,
      userInputText: submitUserTurnDto.inputText,
      inputMode: submitUserTurnDto.inputMode,
      userAudioUrl: submitUserTurnDto.audioUrl,
    });
    
    await this.conversationTurnRepository.save(userTurn);

    // Generate AI response
    const scenario = await this.scenarioRepository.findOne({
      where: { scenarioId: conversation.scenarioId },
    });
    
    const hskLevel = await this.hskLevelRepository.findOne({
      where: { hskLevelId: conversation.hskLevelPlayed },
    });
    
    // Get conversation history
    const conversationHistory = await this.conversationTurnRepository.find({
      where: { conversationId },
      order: { turnNumber: 'ASC' },
    });

    // Generate AI turn
    const aiTurn = await this.generateAiResponse(
      conversation,
      scenario,
      hskLevel,
      submitUserTurnDto,
      conversationHistory,
      nextTurnNumber + 1,
    );

    // Update conversation score
    const updatedScore = conversation.currentScore + this.calculateTurnScore(submitUserTurnDto, aiTurn);
    await this.conversationRepository.update(
      { conversationId },
      { currentScore: updatedScore },
    );

    return {
      aiTurn,
      updatedConversationScore: updatedScore,
    };
  }

  async endConversation(conversationId: string, user: User): Promise<Conversation> {
    const conversation = await this.conversationRepository.findOne({
      where: {
        conversationId,
        userId: user.userId,
      },
    });
    
    if (!conversation) {
      throw new NotFoundException(`Conversation with ID ${conversationId} not found`);
    }

    conversation.isCompleted = true;
    return this.conversationRepository.save(conversation);
  }

  async saveConversation(conversationId: string, saveConversationDto: SaveConversationDto, user: User): Promise<Conversation> {
    const conversation = await this.conversationRepository.findOne({
      where: {
        conversationId,
        userId: user.userId,
      },
    });
    
    if (!conversation) {
      throw new NotFoundException(`Conversation with ID ${conversationId} not found`);
    }

    // Check if user has reached their saved conversation limit (for free tier)
    if (user.settings?.subscriptionTier !== 'premium' && !conversation.isSaved) {
      const savedLimit = this.configService.get<number>('FREE_TIER_SAVED_CONVERSATION_LIMIT', 5);
      
      const savedCount = await this.conversationRepository.count({
        where: {
          userId: user.userId,
          isSaved: true,
        },
      });
      
      if (savedCount >= savedLimit) {
        throw new PaymentRequiredException(`You have reached your limit of ${savedLimit} saved conversations. Upgrade to premium for unlimited saved conversations.`);
      }
    }

    conversation.isSaved = true;
    conversation.savedInstanceName = saveConversationDto.savedInstanceName;
    
    return this.conversationRepository.save(conversation);
  }

  async getConversationTurns(conversationId: string, user: User): Promise<ConversationTurn[]> {
    const conversation = await this.conversationRepository.findOne({
      where: {
        conversationId,
        userId: user.userId,
      },
    });
    
    if (!conversation) {
      throw new NotFoundException(`Conversation with ID ${conversationId} not found`);
    }

    return this.conversationTurnRepository.find({
      where: { conversationId },
      order: { turnNumber: 'ASC' },
    });
  }

  async getUserConversations(userId: string, onlySaved: boolean = false): Promise<Conversation[]> {
    const queryBuilder = this.conversationRepository.createQueryBuilder('conversation')
      .leftJoinAndSelect('conversation.scenario', 'scenario')
      .where('conversation.userId = :userId', { userId });
    
    if (onlySaved) {
      queryBuilder.andWhere('conversation.isSaved = :isSaved', { isSaved: true });
    }
    
    return queryBuilder
      .orderBy('conversation.updatedAt', 'DESC')
      .getMany();
  }

  private async generateInitialAiTurn(conversation: Conversation, scenario: Scenario, hskLevel: HskLevel): Promise<ConversationTurn> {
    // In a real implementation, this would call the AI service
    // For now, we'll create a simple mock response
    const initialResponse = await this.aiService.generateInitialResponse(scenario, hskLevel);
    
    const aiTurn = this.conversationTurnRepository.create({
      conversationId: conversation.conversationId,
      turnNumber: 1,
      speaker: Speaker.AI,
      aiResponseText: initialResponse,
    });
    
    return this.conversationTurnRepository.save(aiTurn);
  }

  private async generateAiResponse(
    conversation: Conversation,
    scenario: Scenario,
    hskLevel: HskLevel,
    userTurn: SubmitUserTurnDto,
    conversationHistory: ConversationTurn[],
    nextTurnNumber: number,
  ): Promise<ConversationTurn> {
    // In a real implementation, this would call the AI service
    // For now, we'll create a simple mock response
    const { responseText, feedback } = await this.aiService.generateResponse(
      scenario,
      hskLevel,
      userTurn,
      conversationHistory,
    );
    
    const aiTurn = this.conversationTurnRepository.create({
      conversationId: conversation.conversationId,
      turnNumber: nextTurnNumber,
      speaker: Speaker.AI,
      aiResponseText: responseText,
      feedback,
    });
    
    return this.conversationTurnRepository.save(aiTurn);
  }

  private calculateTurnScore(userTurn: SubmitUserTurnDto, aiTurn: ConversationTurn): number {
    // In a real implementation, this would be based on the AI's feedback
    // For now, we'll just return a random score between 1 and 10
    return Math.floor(Math.random() * 10) + 1;
  }
}
