import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsMongoId,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedDto } from '../../common/dto/localized.dto';

export class CreateCategoryDto {
  @ApiProperty()
  @ValidateNested()
  @Type(() => LocalizedDto)
  names: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  parentId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  image?: string;

  @ApiPropertyOptional({ enum: ['standard', 'custom', 'both'] })
  @IsOptional()
  @IsIn(['standard', 'custom', 'both'])
  type?: string;

  @ApiPropertyOptional({ enum: ['published', 'unpublished'] })
  @IsOptional()
  @IsIn(['published', 'unpublished'])
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;
}

export class UpdateCategoryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedDto)
  names?: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  parentId?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  image?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn(['standard', 'custom', 'both'])
  type?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn(['published', 'unpublished'])
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;
}

export class CreateCustomFieldDto {
  @ApiProperty()
  @IsMongoId()
  categoryId: string;

  @ApiProperty()
  @ValidateNested()
  @Type(() => LocalizedDto)
  labels: LocalizedDto;

  @ApiProperty()
  @IsIn([
    'text',
    'number',
    'dropdown',
    'multi_select',
    'boolean',
    'size',
    'color',
    'image',
    'textarea',
  ])
  fieldType: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  required?: boolean;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsString({ each: true })
  options?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn(['published', 'unpublished'])
  status?: string;
}

export class UpdateCustomFieldDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedDto)
  labels?: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn([
    'text',
    'number',
    'dropdown',
    'multi_select',
    'boolean',
    'size',
    'color',
    'image',
    'textarea',
  ])
  fieldType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  required?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString({ each: true })
  options?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn(['published', 'unpublished'])
  status?: string;
}

export class ProductVariantDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sku?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  price?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  stock?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  attributes?: Record<string, unknown>;
}

export class ProductFlagsDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  featured?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  newArrival?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  bestSeller?: boolean;
}

export class CreateProductDto {
  @ApiProperty()
  @IsMongoId()
  categoryId: string;

  @ApiProperty()
  @ValidateNested()
  @Type(() => LocalizedDto)
  names: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedDto)
  descriptions?: LocalizedDto;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsString({ each: true })
  images?: string[];

  @ApiProperty()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  salePrice?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  stock?: number;

  @ApiPropertyOptional({ type: [ProductVariantDto] })
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ProductVariantDto)
  variants?: ProductVariantDto[];

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  attributes?: Record<string, unknown>;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsString({ each: true })
  sizes?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => ProductFlagsDto)
  flags?: ProductFlagsDto;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional({ enum: ['published', 'unpublished', 'archived'] })
  @IsOptional()
  @IsIn(['published', 'unpublished', 'archived'])
  status?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsMongoId({ each: true })
  relatedProductIds?: string[];
}

export class UpdateProductDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  categoryId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedDto)
  names?: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => LocalizedDto)
  descriptions?: LocalizedDto;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString({ each: true })
  images?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  salePrice?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  stock?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested({ each: true })
  @Type(() => ProductVariantDto)
  variants?: ProductVariantDto[];

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  attributes?: Record<string, unknown>;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString({ each: true })
  sizes?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @ValidateNested()
  @Type(() => ProductFlagsDto)
  flags?: ProductFlagsDto;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  sortOrder?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsIn(['published', 'unpublished', 'archived'])
  status?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId({ each: true })
  relatedProductIds?: string[];
}
