import { Body, Controller, Post } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { IsIn, IsOptional, IsString } from 'class-validator';
import { Public } from '../common/decorators/public.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { AuthUser } from '../common/types/auth-user';
import { AnalyticsService } from './analytics.service';

class TrackVisitDto {
  @IsIn(['mobile', 'website'])
  platform: 'mobile' | 'website';

  @IsOptional()
  @IsString()
  path?: string;

  @IsOptional()
  @IsString()
  sessionId?: string;
}

@SkipThrottle()
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analytics: AnalyticsService) {}

  @Public()
  @Post('visit')
  track(@Body() dto: TrackVisitDto, @CurrentUser() user?: AuthUser) {
    return this.analytics.track({
      ...dto,
      userId: user?.userId,
    });
  }
}
