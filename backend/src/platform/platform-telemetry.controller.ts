import { Body, Controller, Post, Req } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';
import type { Request } from 'express';
import { Public } from '../common/decorators/public.decorator';
import { PlatformTelemetryService } from './platform-telemetry.service';

class TelemetryDto {
  @IsOptional()
  @IsIn(['crash', 'error', 'issue'])
  kind?: 'crash' | 'error' | 'issue';

  @IsOptional()
  @IsIn(['website', 'admin', 'mobile', 'holder', 'api'])
  channel?: string;

  @IsString()
  @MaxLength(500)
  message: string;

  @IsOptional()
  @IsString()
  @MaxLength(4000)
  stack?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  url?: string;
}

@ApiTags('telemetry')
@Throttle({ default: { limit: 40, ttl: 60000 } })
@Controller('telemetry')
export class PlatformTelemetryController {
  constructor(private readonly telemetry: PlatformTelemetryService) {}

  @Public()
  @Post('events')
  ingest(@Req() req: Request, @Body() dto: TelemetryDto) {
    const client = String(req.headers['x-client'] || '');
    return this.telemetry.ingest({
      ...dto,
      channel: dto.channel || client,
      userAgent: String(req.headers['user-agent'] || ''),
      url: dto.url,
    });
  }
}
