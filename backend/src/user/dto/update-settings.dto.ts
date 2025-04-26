import { IsObject, IsNotEmpty } from 'class-validator';

export class UpdateSettingsDto {
  @IsObject()
  @IsNotEmpty()
  settings: Record<string, any>;
}
