import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { HskLevel } from './hsk-level.entity';
import { User } from '../../user/entities/user.entity';

@Entity('scenarios')
export class Scenario {
  @PrimaryGeneratedColumn('uuid')
  scenarioId: string;

  @Column()
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ default: false })
  isPredefined: boolean;

  @Column({ nullable: true })
  suggestedHskLevelId: number;

  @Column({ nullable: true })
  createdByUserId: string;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @Column({ nullable: true })
  lastUsedAt: Date;

  @ManyToOne(() => HskLevel, hskLevel => hskLevel.scenarios)
  @JoinColumn({ name: 'suggestedHskLevelId' })
  suggestedHskLevel: HskLevel;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'createdByUserId' })
  createdByUser: User;
}
