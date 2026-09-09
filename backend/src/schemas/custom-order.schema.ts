import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes, Types } from 'mongoose';
import { CUSTOM_ORDER_STATUSES } from '../common/constants';

export type CustomOrderDocument = HydratedDocument<CustomOrder>;

@Schema({ _id: true })
export class Proposal {
  @Prop({ required: true })
  version: number;

  @Prop({ required: true })
  productName: string;

  @Prop({ type: [String], default: [] })
  images: string[];

  @Prop()
  description?: string;

  @Prop({ type: SchemaTypes.Mixed })
  specifications?: Record<string, unknown>;

  @Prop({ required: true })
  price: number;

  @Prop({ default: 1 })
  quantity: number;

  @Prop()
  estimatedDays?: number;

  @Prop()
  notes?: string;

  @Prop({
    enum: ['sent', 'confirmed', 'rejected', 'replaced'],
    default: 'sent',
  })
  status: string;

  @Prop()
  customerResponse?: string;

  @Prop()
  respondedAt?: Date;
}

export const ProposalSchema = SchemaFactory.createForClass(Proposal);

@Schema({ timestamps: true })
export class CustomOrder {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Category', required: true })
  categoryId: Types.ObjectId;

  @Prop({ type: SchemaTypes.Mixed, default: {} })
  fields: Record<string, unknown>;

  @Prop()
  description?: string;

  @Prop({ type: [String], default: [] })
  attachments: string[];

  @Prop({ enum: CUSTOM_ORDER_STATUSES, default: 'submitted' })
  status: string;

  @Prop({ type: [ProposalSchema], default: [] })
  proposals: Proposal[];
}

export const CustomOrderSchema = SchemaFactory.createForClass(CustomOrder);
