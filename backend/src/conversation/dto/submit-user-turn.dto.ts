import { IsString, IsNotEmpty, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { InputMode } from '../entities/conversation-turn.entity';

export class SubmitUserTurnDto {
  @ApiProperty({ description: 'The text input from the user' })
  @IsString()
  @IsNotEmpty()
  inputText: string;

  @ApiProperty({ description: 'The input mode (text or voice)', enum: InputMode })
  @IsEnum(InputMode)
  @IsNotEmpty()
  inputMode: InputMode;

  @ApiPropertyOptional({ description: 'URL to the audio file if input mode is voice' })
  @IsString()
  @IsOptional()
  audioUrl?: string;
}
