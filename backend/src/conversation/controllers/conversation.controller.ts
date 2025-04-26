import { Controller, Get, Post, Body, Param, UseGuards, Req, Query, ParseBoolPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ConversationService } from '../services/conversation.service';
import { Conversation } from '../entities/conversation.entity';
import { ConversationTurn } from '../entities/conversation-turn.entity';
import { StartConversationDto } from '../dto/start-conversation.dto';
import { SubmitUserTurnDto } from '../dto/submit-user-turn.dto';
import { SaveConversationDto } from '../dto/save-conversation.dto';

@ApiTags('conversations')
@Controller('conversations')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ConversationController {
  constructor(private readonly conversationService: ConversationService) {}

  @Post()
  @ApiOperation({ summary: 'Start a new conversation' })
  @ApiResponse({ status: 201, description: 'The conversation has been created' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 402, description: 'Premium subscription required or daily limit exceeded' })
  @ApiResponse({ status: 404, description: 'Scenario or HSK level not found' })
  async startConversation(@Body() startConversationDto: StartConversationDto, @Req() req) {
    return this.conversationService.startConversation(startConversationDto, req.user);
  }

  @Post(':conversationId/turns')
  @ApiOperation({ summary: 'Submit a user turn and get AI response' })
  @ApiResponse({ status: 201, description: 'The turn has been processed' })
  @ApiResponse({ status: 400, description: 'Invalid input or conversation already completed' })
  @ApiResponse({ status: 402, description: 'Premium subscription required or daily limit exceeded' })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async submitUserTurn(
    @Param('conversationId') conversationId: string,
    @Body() submitUserTurnDto: SubmitUserTurnDto,
    @Req() req,
  ) {
    return this.conversationService.submitUserTurn(conversationId, submitUserTurnDto, req.user);
  }

  @Post(':conversationId/end')
  @ApiOperation({ summary: 'End a conversation' })
  @ApiResponse({ status: 200, description: 'The conversation has been ended' })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async endConversation(@Param('conversationId') conversationId: string, @Req() req) {
    return this.conversationService.endConversation(conversationId, req.user);
  }

  @Post(':conversationId/save')
  @ApiOperation({ summary: 'Save a conversation' })
  @ApiResponse({ status: 200, description: 'The conversation has been saved' })
  @ApiResponse({ status: 402, description: 'Premium subscription required or limit exceeded' })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async saveConversation(
    @Param('conversationId') conversationId: string,
    @Body() saveConversationDto: SaveConversationDto,
    @Req() req,
  ) {
    return this.conversationService.saveConversation(conversationId, saveConversationDto, req.user);
  }

  @Get(':conversationId/turns')
  @ApiOperation({ summary: 'Get all turns for a conversation' })
  @ApiResponse({ status: 200, description: 'Return all turns', type: [ConversationTurn] })
  @ApiResponse({ status: 404, description: 'Conversation not found' })
  async getConversationTurns(@Param('conversationId') conversationId: string, @Req() req) {
    return this.conversationService.getConversationTurns(conversationId, req.user);
  }

  @Get()
  @ApiOperation({ summary: 'Get all conversations for the current user' })
  @ApiQuery({ name: 'onlySaved', type: Boolean, required: false })
  @ApiResponse({ status: 200, description: 'Return all conversations', type: [Conversation] })
  async getUserConversations(
    @Req() req,
    @Query('onlySaved', new ParseBoolPipe({ optional: true })) onlySaved?: boolean,
  ) {
    return this.conversationService.getUserConversations(req.user.userId, onlySaved);
  }
}
