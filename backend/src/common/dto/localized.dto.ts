import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class LocalizedDto {
  @ApiProperty()
  @IsString()
  en: string;

  @ApiProperty()
  @IsString()
  ar: string;
}

export class OptionalLocalizedDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  en?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  ar?: string;
}
