import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { User } from '../../user/entities/user.entity';
import { Scenario } from '../../content/entities/scenario.entity';
import { ConversationTurn } from './conversation-turn.entity';

@Entity('conversations')
export class Conversation {
  @PrimaryGeneratedColumn('uuid')
  conversationId: string;

  @Column()
  userId: string;

  @Column()
  scenarioId: string;

  @Column()
  hskLevelPlayed: number;

  @Column({ default: false })
  isCompleted: boolean;

  @Column({ default: 0 })
  currentScore: number;

  @Column({ nullable: true })
  inspirationSavedInstanceId: string;

  @Column({ default: false })
  isSaved: boolean;

  @Column({ nullable: true })
  savedInstanceName: string;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Scenario)
  @JoinColumn({ name: 'scenarioId' })
  scenario: Scenario;

  @OneToMany(() => ConversationTurn, turn => turn.conversation)
  turns: ConversationTurn[];
}
