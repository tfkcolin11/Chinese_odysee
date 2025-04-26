import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Scenario } from './scenario.entity';
import { HskLevel } from './hsk-level.entity';

@Entity('scenario_pre_learning_cache')
export class PreLearningContent {
  @PrimaryGeneratedColumn('uuid')
  cacheId: string;

  @Column()
  scenarioId: string;

  @Column()
  hskLevelId: number;

  @Column({ type: 'json' })
  generatedContentJson: Record<string, any>;

  @CreateDateColumn()
  generatedAt: Date;

  @Column()
  expiresAt: Date;

  @ManyToOne(() => Scenario)
  @JoinColumn({ name: 'scenarioId' })
  scenario: Scenario;

  @ManyToOne(() => HskLevel)
  @JoinColumn({ name: 'hskLevelId' })
  hskLevel: HskLevel;
}
