import { Injectable, NotFoundException, BadRequestException, PaymentRequiredException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { PreLearningContent } from '../entities/pre-learning-content.entity';
import { Scenario } from '../entities/scenario.entity';
import { HskLevel } from '../entities/hsk-level.entity';
import { User } from '../../user/entities/user.entity';
import { PreLearningParamsDto } from '../dto/pre-learning-params.dto';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PreLearningService {
  constructor(
    @InjectRepository(PreLearningContent)
    private preLearningRepository: Repository<PreLearningContent>,
    @InjectRepository(Scenario)
    private scenarioRepository: Repository<Scenario>,
    @InjectRepository(HskLevel)
    private hskLevelRepository: Repository<HskLevel>,
    private configService: ConfigService,
  ) {}

  async getPreLearningContent(params: PreLearningParamsDto, user: User): Promise<PreLearningContent> {
    // Check if the scenario exists
    const scenario = await this.scenarioRepository.findOne({
      where: { scenarioId: params.scenarioId },
    });

    if (!scenario) {
      throw new NotFoundException(`Scenario with ID ${params.scenarioId} not found`);
    }

    // Check if the HSK level exists
    const hskLevel = await this.hskLevelRepository.findOne({
      where: { hskLevelId: params.hskLevelId },
    });

    if (!hskLevel) {
      throw new NotFoundException(`HSK level with ID ${params.hskLevelId} not found`);
    }

    // Check if user has access to this feature
    // For custom scenarios, only premium users have access
    if (!scenario.isPredefined && user.settings?.subscriptionTier !== 'premium') {
      throw new PaymentRequiredException('Premium subscription required for pre-learning content on custom scenarios');
    }

    // Check if there's a valid cached content
    const cachedContent = await this.preLearningRepository.findOne({
      where: {
        scenarioId: params.scenarioId,
        hskLevelId: params.hskLevelId,
        expiresAt: LessThan(new Date()),
      },
    });

    if (cachedContent) {
      return cachedContent;
    }

    // Generate new content
    return this.generatePreLearningContent(params, user);
  }

  private async generatePreLearningContent(params: PreLearningParamsDto, user: User): Promise<PreLearningContent> {
    // Check daily limit for free users
    if (user.settings?.subscriptionTier !== 'premium') {
      // In a real implementation, we would check the user's daily usage
      // For now, we'll just simulate it
      const dailyLimit = this.configService.get<number>('FREE_TIER_DAILY_PRELEARN_LIMIT', 5);
      const dailyUsage = 0; // This would be fetched from a usage tracking service

      if (dailyUsage >= dailyLimit) {
        throw new BadRequestException(`You have reached your daily limit of ${dailyLimit} pre-learning generations`);
      }
    }

    // Get the scenario and HSK level
    const scenario = await this.scenarioRepository.findOne({
      where: { scenarioId: params.scenarioId },
    });

    const hskLevel = await this.hskLevelRepository.findOne({
      where: { hskLevelId: params.hskLevelId },
    });

    // In a real implementation, we would call an AI service to generate content
    // For now, we'll just create mock content
    const mockVocabulary = [
      {
        characters: '你好',
        pinyin: 'nǐ hǎo',
        translation: 'hello',
      },
      {
        characters: '谢谢',
        pinyin: 'xiè xiè',
        translation: 'thank you',
      },
      {
        characters: '再见',
        pinyin: 'zài jiàn',
        translation: 'goodbye',
      },
    ];

    const mockGrammarPoints = [
      {
        name: 'Basic Sentence Structure',
        explanation: 'Chinese sentences typically follow Subject-Verb-Object order',
        example: '我喜欢中文 (Wǒ xǐhuān Zhōngwén) - I like Chinese',
      },
      {
        name: 'Question Particles',
        explanation: 'Add 吗 (ma) at the end of a statement to turn it into a yes/no question',
        example: '你喜欢中文吗？ (Nǐ xǐhuān Zhōngwén ma?) - Do you like Chinese?',
      },
    ];

    // Calculate expiry date (7 days from now)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Create and save the pre-learning content
    const preLearningContent = this.preLearningRepository.create({
      scenarioId: params.scenarioId,
      hskLevelId: params.hskLevelId,
      generatedContentJson: {
        vocabulary: mockVocabulary,
        grammarPoints: mockGrammarPoints,
        scenario: {
          name: scenario.name,
          description: scenario.description,
        },
        hskLevel: {
          name: hskLevel.name,
          level: hskLevel.level,
        },
        generatedAt: new Date().toISOString(),
      },
      expiresAt,
    });

    return this.preLearningRepository.save(preLearningContent);
  }

  async clearExpiredCache(): Promise<void> {
    const now = new Date();
    await this.preLearningRepository.delete({
      expiresAt: LessThan(now),
    });
  }
}
