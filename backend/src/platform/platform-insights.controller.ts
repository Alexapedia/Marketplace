import { Controller, Get, Param, Patch, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { PlatformJwtGuard } from './platform-jwt.guard';
import { PlatformInsightsService } from './platform-insights.service';
import { PlatformTelemetryService } from './platform-telemetry.service';

@ApiTags('platform')
@ApiBearerAuth()
@UseGuards(PlatformJwtGuard)
@Controller('platform')
export class PlatformInsightsController {
  constructor(
    private readonly insights: PlatformInsightsService,
    private readonly telemetry: PlatformTelemetryService,
  ) {}

  @Get('reports')
  reports() {
    return this.insights.reports();
  }

  @Get('issues')
  issues(
    @Query('status') status?: string,
    @Query('channel') channel?: string,
    @Query('tenantId') tenantId?: string,
  ) {
    return this.telemetry.list({ status, channel, tenantId });
  }

  @Patch('issues/:id')
  resolve(@Param('id') id: string) {
    return this.telemetry.resolve(id);
  }
}
