import { Module } from '@nestjs/common';
import { AnalyticsModule } from '../analytics/analytics.module';
import { AppConfigModule } from '../app-config/app-config.module';
import { CatalogModule } from '../catalog/catalog.module';
import { CustomOrdersModule } from '../custom-orders/custom-orders.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { OrdersModule } from '../orders/orders.module';
import { ReviewsModule } from '../reviews/reviews.module';
import { UploadsModule } from '../uploads/uploads.module';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';

@Module({
  imports: [
    CatalogModule,
    OrdersModule,
    CustomOrdersModule,
    NotificationsModule,
    AppConfigModule,
    AnalyticsModule,
    ReviewsModule,
    UploadsModule,
  ],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
