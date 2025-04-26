import { IsString, IsNotEmpty, IsOptional, IsNumber, IsBoolean, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateScenarioDto {
  @ApiProperty({ description: 'The name of the scenario' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'The description of the scenario' })
  @IsString()
  @IsNotEmpty()
  description: string;

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
