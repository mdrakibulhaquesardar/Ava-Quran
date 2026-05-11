import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCollectionDto {
  @ApiProperty({ example: 'Ramadan Favs', description: 'Collection display name' })
  @IsString()
  @IsNotEmpty()
  title: string;
}
