import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { PlatformAuthController } from './platform-auth.controller';
import { PlatformAuthService } from './platform-auth.service';
import { PlatformInsightsController } from './platform-insights.controller';
import { PlatformInsightsService } from './platform-insights.service';
import { PlatformJwtGuard } from './platform-jwt.guard';
import { PlatformJwtStrategy } from './platform-jwt.strategy';
import { PlatformTelemetryController } from './platform-telemetry.controller';
import { PlatformTenantsController } from './platform-tenants.controller';
import { PlatformTenantsService } from './platform-tenants.service';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        secret:
          config.get<string>('JWT_PLATFORM_SECRET') ||
          config.get<string>('JWT_SECRET') ||
          'change-me-in-production',
        signOptions: { expiresIn: '8h' },
      }),
    }),
  ],
  controllers: [
    PlatformAuthController,
    PlatformTenantsController,
    PlatformInsightsController,
    PlatformTelemetryController,
  ],
  providers: [
    PlatformAuthService,
    PlatformJwtStrategy,
    PlatformJwtGuard,
    PlatformTenantsService,
    PlatformInsightsService,
  ],
})
export class PlatformModule {}
