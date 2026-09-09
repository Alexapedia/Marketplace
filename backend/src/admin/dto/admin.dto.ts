import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsIn, IsMongoId, IsObject, IsOptional, IsString } from 'class-validator';
import { LocalizedDto } from '../../common/dto/localized.dto';
import { PaginationDto } from '../../common/dto/pagination.dto';

export class AdminListQuery extends PaginationDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sort?: string;
}

export class PatchCustomerDto {
  @ApiProperty({ enum: ['active', 'blocked'] })
  @IsIn(['active', 'blocked'])
  status: string;
}

export class SendNotificationDto {
  @ApiProperty()
  @IsObject()
  title: LocalizedDto;

  @ApiProperty()
  @IsObject()
  body: LocalizedDto;

  @ApiProperty({ enum: ['all', 'userIds'] })
  @IsIn(['all', 'userIds'])
  target: 'all' | 'userIds';

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  userIds?: string[];
}

export class UpdateRoleDto {
  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsString({ each: true })
  permissions?: string[];
}

export class ReportsQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  from?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  to?: string;
}

export class PatchAppConfigDto {
  @ApiPropertyOptional()
  @IsOptional()
  banners?: unknown[];

  @ApiPropertyOptional()
  @IsOptional()
  onboarding?: unknown[];

  @ApiPropertyOptional()
  @IsOptional()
  version?: Record<string, unknown>;

  @ApiPropertyOptional()
  @IsOptional()
  settings?: Record<string, unknown>;
}
