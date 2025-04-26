import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { Conversation } from './entities/conversation.entity';
import { ConversationTurn } from './entities/conversation-turn.entity';
import { Scenario } from '../content/entities/scenario.entity';
import { HskLevel } from '../content/entities/hsk-level.entity';
import { ConversationController } from './controllers/conversation.controller';
import { ConversationService } from './services/conversation.service';
import { AiService } from './services/ai.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Conversation, ConversationTurn, Scenario, HskLevel]),
    ConfigModule,
  ],
  controllers: [ConversationController],
  providers: [ConversationService, AiService],
  exports: [ConversationService],
})
export class ConversationModule {}
