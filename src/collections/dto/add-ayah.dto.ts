import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddAyahDto {
  @ApiProperty({ example: '2:255', description: 'Ayah key to reference' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d+:\d+$/, { message: 'Invalid Ayah Key format (expected "chapter:verse")' })
  ayahKey: string;
}
