import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export const REVIEW_TARGETS = ['product', 'order', 'app', 'website'] as const;
export type ReviewTarget = (typeof REVIEW_TARGETS)[number];

export type ReviewDocument = HydratedDocument<Review>;

@Schema({ timestamps: true })
export class Review {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true, index: true })
  userId: Types.ObjectId;

  @Prop({ required: true, enum: REVIEW_TARGETS, index: true })
  targetType: ReviewTarget;

  @Prop({ type: Types.ObjectId, index: true })
  targetId?: Types.ObjectId;

  @Prop({ required: true })
  scope: string;

  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Prop({ trim: true, default: '' })
  comment: string;

  @Prop({ type: { en: String, ar: String } })
  targetName?: { en: string; ar: string };

  @Prop({ default: false, index: true })
  hidden: boolean;
}

export const ReviewSchema = SchemaFactory.createForClass(Review);
ReviewSchema.index({ userId: 1, scope: 1 }, { unique: true });
ReviewSchema.index({ targetType: 1, hidden: 1, rating: 1, createdAt: -1 });
