import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes } from 'mongoose';

export type PlatformEventDocument = HydratedDocument<PlatformEvent>;

@Schema({ timestamps: true })
export class PlatformEvent {
  @Prop({ required: true, index: true, unique: true })
  fingerprint: string;

  @Prop({ required: true, enum: ['crash', 'error', 'issue'], index: true })
  kind: 'crash' | 'error' | 'issue';

  @Prop({
    required: true,
    enum: ['website', 'admin', 'mobile', 'holder', 'api'],
    index: true,
  })
  channel: string;

  @Prop({ index: true })
  tenantId?: string;

  @Prop({ required: true })
  message: string;

  @Prop()
  stack?: string;

  @Prop()
  url?: string;

  @Prop()
  userAgent?: string;

  @Prop({ type: SchemaTypes.Mixed })
  meta?: unknown;

  @Prop({ default: 1 })
  count: number;

  @Prop({ default: Date.now, index: true })
  firstSeen: Date;

  @Prop({ default: Date.now, index: true })
  lastSeen: Date;

  @Prop({ enum: ['open', 'resolved'], default: 'open', index: true })
  status: 'open' | 'resolved';
}

export const PlatformEventSchema = SchemaFactory.createForClass(PlatformEvent);
PlatformEventSchema.index({ status: 1, lastSeen: -1 });
PlatformEventSchema.index({ tenantId: 1, status: 1, lastSeen: -1 });
