import { IsString, IsNotEmpty, IsNumber } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PreLearningParamsDto {
  @ApiProperty({ description: 'The ID of the scenario' })
  @IsString()
  @IsNotEmpty()
  scenarioId: string;

  @ApiProperty({ description: 'The HSK level ID' })
  @IsNumber()
  @IsNotEmpty()
  hskLevelId: number;
}
