import { Global, MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PlatformAudit, PlatformAuditSchema } from '../schemas/platform-audit.schema';
import { PlatformEvent, PlatformEventSchema } from '../schemas/platform-event.schema';
import { PlatformUser, PlatformUserSchema } from '../schemas/platform-user.schema';
import { Tenant, TenantSchema } from '../schemas/tenant.schema';
import { TenantMiddleware } from './tenant.middleware';
import { TenantService } from './tenant.service';
import { TotpService } from './totp.service';
import { PlatformTelemetryService } from '../platform/platform-telemetry.service';

@Global()
@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Tenant.name, schema: TenantSchema },
      { name: PlatformUser.name, schema: PlatformUserSchema },
      { name: PlatformAudit.name, schema: PlatformAuditSchema },
      { name: PlatformEvent.name, schema: PlatformEventSchema },
    ]),
  ],
  providers: [TenantService, TotpService, PlatformTelemetryService],
  exports: [TenantService, TotpService, PlatformTelemetryService, MongooseModule],
})
export class TenantModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(TenantMiddleware).forRoutes('*');
  }
}
