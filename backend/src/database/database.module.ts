import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppConfig, AppConfigSchema } from '../schemas/app-config.schema';
import { AuditLog, AuditLogSchema } from '../schemas/audit-log.schema';
import { Cart, CartSchema } from '../schemas/cart.schema';
import { Category, CategorySchema } from '../schemas/category.schema';
import { Conversation, ConversationSchema } from '../schemas/conversation.schema';
import { CustomField, CustomFieldSchema } from '../schemas/custom-field.schema';
import { CustomOrder, CustomOrderSchema } from '../schemas/custom-order.schema';
import { Favorite, FavoriteSchema } from '../schemas/favorite.schema';
import { Message, MessageSchema } from '../schemas/message.schema';
import { Notification, NotificationSchema } from '../schemas/notification.schema';
import { Order, OrderSchema } from '../schemas/order.schema';
import {
  PasswordReset,
  PasswordResetSchema,
} from '../schemas/password-reset.schema';
import { Product, ProductSchema } from '../schemas/product.schema';
import { Role, RoleSchema } from '../schemas/role.schema';
import { User, UserSchema } from '../schemas/user.schema';

const models = [
  { name: User.name, schema: UserSchema },
  { name: Role.name, schema: RoleSchema },
  { name: Category.name, schema: CategorySchema },
  { name: CustomField.name, schema: CustomFieldSchema },
  { name: Product.name, schema: ProductSchema },
  { name: Favorite.name, schema: FavoriteSchema },
  { name: Cart.name, schema: CartSchema },
  { name: Order.name, schema: OrderSchema },
  { name: CustomOrder.name, schema: CustomOrderSchema },
  { name: Conversation.name, schema: ConversationSchema },
  { name: Message.name, schema: MessageSchema },
  { name: Notification.name, schema: NotificationSchema },
  { name: AppConfig.name, schema: AppConfigSchema },
  { name: AuditLog.name, schema: AuditLogSchema },
  { name: PasswordReset.name, schema: PasswordResetSchema },
];

@Global()
@Module({
  imports: [MongooseModule.forFeature(models)],
  exports: [MongooseModule],
})
export class DatabaseModule {}
