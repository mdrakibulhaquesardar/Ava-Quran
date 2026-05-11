import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpdatePreferencesDto {
  @ApiPropertyOptional({ example: 'en', description: 'Preferred UI/Translation language' })
  @IsOptional()
  @IsString()
  preferredLanguage?: string;

  @ApiPropertyOptional({ example: '7', description: 'Favorite reciter identifier' })
  @IsOptional()
  @IsString()
  favoriteReciter?: string;

  @ApiPropertyOptional({ example: 'peaceful', description: 'User default mood' })
  @IsOptional()
  @IsString()
  moodPreference?: string;
}
