import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString } from 'class-validator';
import { Public } from '../common/decorators/public.decorator';
import { AppConfigService } from './app-config.service';

class VersionQueryDto {
  @IsOptional()
  @IsString()
  @IsIn(['ios', 'android'])
  platform?: string;
}

@ApiTags('app')
@Controller('app')
export class AppConfigController {
  constructor(private readonly appConfig: AppConfigService) {}

  @Public()
  @Get('config')
  getConfig() {
    return this.appConfig.getPublic();
  }

  @Public()
  @Get('version')
  getVersion(@Query() query: VersionQueryDto) {
    return this.appConfig.getVersion(query.platform);
  }
}
