import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { HskLevel } from './entities/hsk-level.entity';
import { Scenario } from './entities/scenario.entity';
import { PreLearningContent } from './entities/pre-learning-content.entity';
import { HskLevelController } from './controllers/hsk-level.controller';
import { ScenarioController } from './controllers/scenario.controller';
import { PreLearningController } from './controllers/pre-learning.controller';
import { HskLevelService } from './services/hsk-level.service';
import { ScenarioService } from './services/scenario.service';
import { PreLearningService } from './services/pre-learning.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([HskLevel, Scenario, PreLearningContent]),
    ConfigModule,
  ],
  controllers: [
    HskLevelController,
    ScenarioController,
    PreLearningController,
  ],
  providers: [
    HskLevelService,
    ScenarioService,
    PreLearningService,
  ],
  exports: [
    HskLevelService,
    ScenarioService,
    PreLearningService,
  ],
})
export class ContentModule {}
