import { IsString, IsNotEmpty, IsNumber, IsOptional, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateHskLevelDto {
  @ApiProperty({ description: 'The name of the HSK level' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'The description of the HSK level' })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ description: 'The numeric level (1-6)' })
  @IsNumber()
  @IsNotEmpty()
  level: number;

  @ApiPropertyOptional({ description: 'Additional metadata for the HSK level' })
  @IsObject()
  @IsOptional()
  metadata?: Record<string, any>;
}
