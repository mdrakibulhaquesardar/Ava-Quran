import { IsString, IsNotEmpty, Matches } from 'class-validator';

export class AiRequestDto {
  @IsNotEmpty()
  @IsString()
  @Matches(/^\d+:\d+$/, { message: 'ayahKey must be in "chapter:verse" format e.g. 1:5' })
  ayahKey: string;
}
