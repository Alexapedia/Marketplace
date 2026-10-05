import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type VisitDocument = HydratedDocument<Visit>;

@Schema({ timestamps: true })
export class Visit {
  @Prop({ enum: ['mobile', 'website'], required: true, index: true })
  platform: string;

  @Prop()
  path?: string;

  @Prop({ index: true })
  sessionId?: string;

  @Prop({ type: Types.ObjectId, ref: 'User' })
  userId?: Types.ObjectId;
}

export const VisitSchema = SchemaFactory.createForClass(Visit);
VisitSchema.index({ createdAt: -1 });
VisitSchema.index({ platform: 1, sessionId: 1, createdAt: -1 });
