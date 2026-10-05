import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes, Types } from 'mongoose';

export type NotificationDocument = HydratedDocument<Notification>;

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ type: { en: String, ar: String }, required: true })
  title: { en: string; ar: string };

  @Prop({ type: { en: String, ar: String }, required: true })
  body: { en: string; ar: string };

  @Prop({ required: true })
  type: string;

  @Prop({ type: SchemaTypes.Mixed })
  data?: Record<string, unknown>;

  @Prop({ index: true })
  batchId?: string;

  @Prop()
  readAt?: Date;
}

export const NotificationSchema = SchemaFactory.createForClass(Notification);
