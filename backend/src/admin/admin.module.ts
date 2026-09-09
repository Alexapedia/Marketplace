import { Module } from '@nestjs/common';
import { AppConfigModule } from '../app-config/app-config.module';
import { CatalogModule } from '../catalog/catalog.module';
import { CustomOrdersModule } from '../custom-orders/custom-orders.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { OrdersModule } from '../orders/orders.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [
    CatalogModule,
    OrdersModule,
    CustomOrdersModule,
    NotificationsModule,
    AppConfigModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
