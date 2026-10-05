import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsMongoId,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { PaginationDto } from '../../common/dto/pagination.dto';
import { REVIEW_TARGETS } from '../../schemas/review.schema';

export class CreateReviewDto {
  @ApiProperty({ enum: REVIEW_TARGETS })
  @IsIn([...REVIEW_TARGETS])
  targetType: (typeof REVIEW_TARGETS)[number];

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  targetId?: string;

  @ApiProperty({ minimum: 1, maximum: 5 })
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(800)
  comment?: string;
}

export class ListReviewsQuery extends PaginationDto {
  @ApiPropertyOptional({ enum: REVIEW_TARGETS })
  @IsOptional()
  @IsIn([...REVIEW_TARGETS])
  targetType?: (typeof REVIEW_TARGETS)[number];

  @ApiPropertyOptional()
  @IsOptional()
  @IsMongoId()
  targetId?: string;
}

export class AdminListReviewsQuery extends ListReviewsQuery {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  hidden?: string;
}

export class PatchReviewDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  hidden?: boolean;
}
