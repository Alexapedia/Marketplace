import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import {
  IsArray,
  IsBoolean,
  IsEmail,
  IsIn,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import type { Request } from 'express';
import { PlatformJwtGuard } from './platform-jwt.guard';
import type { PlatformAuthUser } from './platform-jwt.strategy';
import { PlatformTenantsService } from './platform-tenants.service';

class DomainDto {
  @IsString()
  host: string;

  @IsIn(['website', 'admin'])
  channel: 'website' | 'admin';
}

class CreateTenantDto {
  @IsString()
  slug: string;

  @IsString()
  name: string;

  @IsEmail()
  adminEmail: string;

  @IsString()
  @MinLength(8)
  adminPassword: string;

  @IsOptional()
  @IsString()
  adminName?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => DomainDto)
  domains?: DomainDto[];

  @IsOptional()
  @IsObject()
  branding?: Record<string, string>;

  @IsOptional()
  @IsString()
  currency?: string;
}

class PatchTenantDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => DomainDto)
  domains?: DomainDto[];

  @IsOptional()
  @IsObject()
  branding?: Record<string, string>;

  @IsOptional()
  @IsString()
  currency?: string;
}

class ChannelDto {
  @IsIn(['website', 'admin', 'mobile'])
  channel: 'website' | 'admin' | 'mobile';

  @IsBoolean()
  enabled: boolean;
}

class StatusDto {
  @IsIn(['active', 'suspended'])
  status: 'active' | 'suspended';
}

@ApiTags('platform')
@ApiBearerAuth()
@UseGuards(PlatformJwtGuard)
@Controller('platform')
export class PlatformTenantsController {
  constructor(private readonly tenants: PlatformTenantsService) {}

  @Get('overview')
  overview() {
    return this.tenants.overview();
  }

  @Get('tenants')
  list() {
    return this.tenants.list();
  }

  @Get('tenants/:id')
  get(@Param('id') id: string) {
    return this.tenants.get(id);
  }

  @Post('tenants')
  create(
    @Req() req: Request & { user: PlatformAuthUser },
    @Body() dto: CreateTenantDto,
  ) {
    return this.tenants.create(req.user.userId, req.ip, dto);
  }

  @Patch('tenants/:id')
  patch(
    @Req() req: Request & { user: PlatformAuthUser },
    @Param('id') id: string,
    @Body() body: PatchTenantDto,
  ) {
    return this.tenants.patch(req.user.userId, req.ip, id, body as unknown as Record<string, unknown>);
  }

  @Patch('tenants/:id/channels')
  channel(
    @Req() req: Request & { user: PlatformAuthUser },
    @Param('id') id: string,
    @Body() dto: ChannelDto,
  ) {
    return this.tenants.setChannel(req.user.userId, req.ip, id, dto.channel, dto.enabled);
  }

  @Patch('tenants/:id/status')
  status(
    @Req() req: Request & { user: PlatformAuthUser },
    @Param('id') id: string,
    @Body() dto: StatusDto,
  ) {
    return this.tenants.setStatus(req.user.userId, req.ip, id, dto.status);
  }

  @Post('tenants/:id/staff/:userId/reset-2fa')
  reset2fa(
    @Req() req: Request & { user: PlatformAuthUser },
    @Param('id') id: string,
    @Param('userId') userId: string,
  ) {
    return this.tenants.resetStaff2fa(req.user.userId, req.ip, id, userId);
  }

  @Get('audit')
  audit(@Query('tenantId') tenantId?: string) {
    return this.tenants.audits(tenantId);
  }
}
