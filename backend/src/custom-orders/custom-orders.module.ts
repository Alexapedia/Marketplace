import { Module } from '@nestjs/common';
import { AddressesModule } from '../addresses/addresses.module';
import { AuditModule } from '../audit/audit.module';
import { ChatRealtimeService } from '../chat/chat-realtime.service';
import { NotificationsModule } from '../notifications/notifications.module';
import { OrdersModule } from '../orders/orders.module';
import { UploadsModule } from '../uploads/uploads.module';
import { CustomOrdersController } from './custom-orders.controller';
import { CustomOrdersService } from './custom-orders.service';

@Module({
  imports: [
    OrdersModule,
    NotificationsModule,
    AuditModule,
    UploadsModule,
    AddressesModule,
  ],
  controllers: [CustomOrdersController],
  providers: [CustomOrdersService, ChatRealtimeService],
  exports: [CustomOrdersService, ChatRealtimeService],
})
export class CustomOrdersModule {}
