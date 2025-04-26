import { IsString, IsOptional, IsNumber, IsObject } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateHskLevelDto {
  @ApiPropertyOptional({ description: 'The name of the HSK level' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ description: 'The description of the HSK level' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'The numeric level (1-6)' })
  @IsNumber()
  @IsOptional()
  level?: number;

  @ApiPropertyOptional({ description: 'Additional metadata for the HSK level' })
  @IsObject()
  @IsOptional()
  metadata?: Record<string, any>;
}
