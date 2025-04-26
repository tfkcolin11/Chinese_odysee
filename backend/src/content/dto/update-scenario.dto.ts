import { IsString, IsOptional, IsNumber, IsBoolean, IsObject } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateScenarioDto {
  @ApiPropertyOptional({ description: 'The name of the scenario' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ description: 'The description of the scenario' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Whether the scenario is predefined' })
  @IsBoolean()
  @IsOptional()
  isPredefined?: boolean;

  @ApiPropertyOptional({ description: 'The suggested HSK level ID for this scenario' })
  @IsNumber()
  @IsOptional()
  suggestedHskLevelId?: number;

  @ApiPropertyOptional({ description: 'Additional metadata for the scenario' })
  @IsObject()
  @IsOptional()
  metadata?: Record<string, any>;
}
