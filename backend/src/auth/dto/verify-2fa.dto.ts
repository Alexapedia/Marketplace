import { ApiProperty } from '@nestjs/swagger';
import { IsString, Length } from 'class-validator';

export class Verify2faDto {
  @ApiProperty()
  @IsString()
  challengeToken: string;

  @ApiProperty()
  @IsString()
  @Length(6, 12)
  code: string;
}
