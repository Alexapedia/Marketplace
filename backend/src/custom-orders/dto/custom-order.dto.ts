import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsMongoId,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { OrderAddressDto } from '../../orders/dto/order.dto';

export class CreateCustomOrderDto {
  @ApiProperty()
  @IsMongoId()
  categoryId: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  fields?: Record<string, unknown>;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ enum: ['draft', 'submitted'] })
  @IsOptional()
  @IsIn(['draft', 'submitted'])
  status?: string;
}

export class ConfirmProposalDto {
  @ApiProperty()
  @IsMongoId()
  proposalId: string;

  @ApiPropertyOptional()
  @IsOptional()
  address?: OrderAddressDto;
}

export class RejectProposalDto {
  @ApiProperty()
  @IsMongoId()
  proposalId: string;

  @ApiProperty()
  @IsString()
  reason: string;

  @ApiPropertyOptional({ enum: ['rejected', 'need_more_details'] })
  @IsOptional()
  @IsIn(['rejected', 'need_more_details'])
  nextStatus?: string;
}

export class CreateProposalDto {
  @ApiProperty()
  @IsString()
  productName: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsString({ each: true })
  images?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  specifications?: Record<string, unknown>;

  @ApiProperty()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  quantity?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  estimatedDays?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;
}

export class CreateMessageDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  text?: string;

  @ApiPropertyOptional({ enum: ['text', 'image', 'file', 'system', 'proposal'] })
  @IsOptional()
  @IsIn(['text', 'image', 'file', 'system', 'proposal'])
  type?: string;
}

export class AdminUpdateCustomOrderDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}
