import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsIn,
  IsMongoId,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
  MinLength,
  ValidateIf,
  ValidateNested,
} from 'class-validator';

export class OrderAddressDto {
  @ApiProperty()
  @IsString()
  fullName: string;

  @ApiProperty()
  @IsString()
  phone: string;

  @ApiProperty()
  @IsString()
  city: string;

  @ApiProperty()
  @IsString()
  street: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng?: number;
}

export class CreateOrderDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => OrderAddressDto)
  address?: OrderAddressDto;

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  addressId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiProperty({ enum: ['COD'] })
  @IsIn(['COD'])
  paymentMethod: 'COD';

  @ApiPropertyOptional({ enum: ['mobile', 'website'] })
  @IsOptional()
  @IsIn(['mobile', 'website'])
  channel?: 'mobile' | 'website';
}

export class ChangeOrderStatusDto {
  @ApiProperty()
  @IsString()
  status: string;

  @ApiPropertyOptional()
  @ValidateIf((dto: ChangeOrderStatusDto) => dto.status === 'rejected')
  @IsString()
  @MinLength(3)
  rejectionReason?: string;
}

export class AdminUpdateOrderDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => OrderAddressDto)
  address?: OrderAddressDto;
}
