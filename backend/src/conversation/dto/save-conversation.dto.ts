import { IsString, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class SaveConversationDto {
  @ApiPropertyOptional({ description: 'Custom name for the saved conversation instance' })
  @IsString()
  @IsOptional()
  savedInstanceName?: string;
}
