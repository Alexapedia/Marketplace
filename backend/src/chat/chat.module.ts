import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { CustomOrdersModule } from '../custom-orders/custom-orders.module';
import { ChatGateway } from './chat.gateway';

@Module({
  imports: [AuthModule, CustomOrdersModule],
  providers: [ChatGateway],
})
export class ChatModule {}
