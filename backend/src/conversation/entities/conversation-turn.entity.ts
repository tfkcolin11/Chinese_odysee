import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Conversation } from './conversation.entity';

export enum Speaker {
  USER = 'user',
  AI = 'ai',
}

export enum InputMode {
  TEXT = 'text',
  VOICE = 'voice',
}

@Entity('conversation_turns')
export class ConversationTurn {
  @PrimaryGeneratedColumn('uuid')
  turnId: string;

  @Column()
  conversationId: string;

  @Column()
  turnNumber: number;

  @Column({
    type: 'enum',
    enum: Speaker,
  })
  speaker: Speaker;

  @Column({ nullable: true })
  userInputText: string;

  @Column({
    type: 'enum',
    enum: InputMode,
    nullable: true,
  })
  inputMode: InputMode;

  @Column({ nullable: true })
  userAudioUrl: string;

  @Column({ nullable: true })
  aiResponseText: string;

  @Column({ nullable: true })
  aiAudioUrl: string;

  @Column({ type: 'json', nullable: true })
  feedback: Record<string, any>;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn()
  timestamp: Date;

  @ManyToOne(() => Conversation, conversation => conversation.turns)
  @JoinColumn({ name: 'conversationId' })
  conversation: Conversation;
}
