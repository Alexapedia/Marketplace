import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import {
  ORDER_STATUSES,
  PAYMENT_METHODS,
  PAYMENT_STATUSES,
} from '../common/constants';

export type OrderDocument = HydratedDocument<Order>;

@Schema({ _id: false })
export class OrderItem {
  @Prop({ type: Types.ObjectId, ref: 'Product' })
  productId?: Types.ObjectId;

  @Prop({ required: true })
  nameSnapshot: string;

  @Prop()
  image?: string;

  @Prop({ required: true })
  unitPrice: number;

  @Prop({ required: true, min: 1 })
  quantity: number;

  @Prop()
  variant?: string;

  @Prop()
  size?: string;
}

export const OrderItemSchema = SchemaFactory.createForClass(OrderItem);

@Schema({ _id: false })
export class OrderAddress {
  @Prop({ required: true })
  fullName: string;

  @Prop({ required: true })
  phone: string;

  @Prop({ required: true })
  city: string;

  @Prop({ required: true })
  street: string;

  @Prop()
  notes?: string;
}

export const OrderAddressSchema = SchemaFactory.createForClass(OrderAddress);

@Schema({ _id: true })
export class StatusHistoryEntry {
  @Prop({ required: true })
  status: string;

  @Prop({ default: Date.now })
  at: Date;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  actorId?: Types.ObjectId;

  @Prop()
  note?: string;
}

export const StatusHistoryEntrySchema =
  SchemaFactory.createForClass(StatusHistoryEntry);

@Schema({ timestamps: true })
export class Order {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ required: true, unique: true })
  orderNumber: string;

  @Prop({ type: [OrderItemSchema], default: [] })
  items: OrderItem[];

  @Prop({ type: OrderAddressSchema, required: true })
  address: OrderAddress;

  @Prop({ required: true })
  subtotal: number;

  @Prop({ default: 0 })
  discount: number;

  @Prop({ default: 0 })
  deliveryFee: number;

  @Prop({ required: true })
  total: number;

  @Prop({ enum: PAYMENT_METHODS, default: 'COD' })
  paymentMethod: string;

  @Prop({ enum: PAYMENT_STATUSES, default: 'pending' })
  paymentStatus: string;

  @Prop()
  transactionReference?: string;

  @Prop({ enum: ORDER_STATUSES, default: 'pending' })
  orderStatus: string;

  @Prop()
  rejectionReason?: string;

  @Prop()
  notes?: string;

  @Prop({ type: [StatusHistoryEntrySchema], default: [] })
  statusHistory: StatusHistoryEntry[];

  @Prop({ sparse: true })
  idempotencyKey?: string;

  @Prop({ type: Types.ObjectId, ref: 'CustomOrder' })
  customOrderId?: Types.ObjectId;
}

export const OrderSchema = SchemaFactory.createForClass(Order);
OrderSchema.index(
  { userId: 1, idempotencyKey: 1 },
  { unique: true, sparse: true },
);
