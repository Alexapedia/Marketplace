import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class FirebaseAuthDto {
  @ApiProperty()
  @IsString()
  idToken: string;
}
