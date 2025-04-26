import { IsString, IsNotEmpty, IsNumber, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class StartConversationDto {
  @ApiProperty({ description: 'The ID of the scenario to use for the conversation' })
  @IsString()
  @IsNotEmpty()
  scenarioId: string;

  @ApiProperty({ description: 'The HSK level to play at' })
  @IsNumber()
  @IsNotEmpty()
  hskLevelPlayed: number;

  @ApiPropertyOptional({ description: 'ID of a saved conversation instance to use as inspiration' })
  @IsString()
  @IsOptional()
  inspirationSavedInstanceId?: string;
}
