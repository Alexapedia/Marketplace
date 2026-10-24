import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { Request } from 'express';
import { Public } from '../common/decorators/public.decorator';
import { LoginDto } from '../auth/dto/login.dto';
import { Verify2faDto } from '../auth/dto/verify-2fa.dto';
import { PlatformAuthService } from './platform-auth.service';
import { PlatformJwtGuard } from './platform-jwt.guard';
import type { PlatformAuthUser } from './platform-jwt.strategy';

@ApiTags('platform-auth')
@Throttle({ default: { limit: 8, ttl: 60000 } })
@Controller('platform/auth')
export class PlatformAuthController {
  constructor(private readonly auth: PlatformAuthService) {}

  @Public()
  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @Public()
  @Post('2fa/verify')
  verify(@Body() dto: Verify2faDto) {
    return this.auth.verify(dto.challengeToken, dto.code);
  }

  @Public()
  @Post('2fa/setup')
  setup(@Body() dto: Verify2faDto) {
    return this.auth.setup(dto.challengeToken, dto.code);
  }

  @ApiBearerAuth()
  @UseGuards(PlatformJwtGuard)
  @Get('me')
  me(@Req() req: Request & { user: PlatformAuthUser }) {
    return this.auth.me(req.user.userId);
  }
}
