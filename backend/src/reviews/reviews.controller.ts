import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import type { AuthUser } from '../common/types/auth-user';
import { CreateReviewDto, ListReviewsQuery } from './dto/review.dto';
import { ReviewsService } from './reviews.service';

@ApiTags('reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviews: ReviewsService) {}

  @Public()
  @Get('highlights')
  highlights(@Query('limit') limit?: string) {
    return this.reviews.highlights(limit ? Number(limit) : 12);
  }

  @Public()
  @Get()
  list(@Query() query: ListReviewsQuery, @CurrentUser() user?: AuthUser) {
    return this.reviews.listPublic({
      targetType: query.targetType,
      targetId: query.targetId,
      page: query.page,
      limit: query.limit,
      user,
    });
  }

  @ApiBearerAuth()
  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateReviewDto) {
    return this.reviews.create(user, dto);
  }
}
