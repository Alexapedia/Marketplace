import { Module } from '@nestjs/common';
import { AddressesModule } from '../addresses/addresses.module';
import { AppConfigModule } from '../app-config/app-config.module';
import { AuditModule } from '../audit/audit.module';
import { CartModule } from '../cart/cart.module';
import { CatalogModule } from '../catalog/catalog.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';

@Module({
  imports: [
    CartModule,
    CatalogModule,
    AppConfigModule,
    AuditModule,
    NotificationsModule,
    AddressesModule,
  ],
  controllers: [OrdersController],
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}
