import { Controller, Get } from '@nestjs/common';
import { InjectConnection } from '@nestjs/mongoose';
import { ApiTags } from '@nestjs/swagger';
import { Connection } from 'mongoose';
import { Public } from '../common/decorators/public.decorator';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(@InjectConnection() private readonly connection: Connection) {}

  @Public()
  @Get()
  async check() {
    const db = this.connection.readyState === 1 ? 'up' : 'down';
    return {
      status: db === 'up' ? 'ok' : 'degraded',
      service: 'placemarket-api',
      db,
      timestamp: new Date().toISOString(),
    };
  }
}
