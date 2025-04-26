import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { Scenario } from './scenario.entity';

@Entity('hsk_levels')
export class HskLevel {
  @PrimaryGeneratedColumn()
  hskLevelId: number;

  @Column()
  name: string;

  @Column()
  description: string;

  @Column()
  level: number;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Scenario, scenario => scenario.suggestedHskLevel)
  scenarios: Scenario[];
}
