import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export const AD_PLACEMENTS = ['home', 'products', 'both'] as const;
export type AdPlacement = (typeof AD_PLACEMENTS)[number];

export type AdDocument = HydratedDocument<Ad>;

@Schema({ timestamps: true })
export class Ad {
  @Prop({ default: '' })
  image: string;

  @Prop({ type: { en: String, ar: String }, default: { en: '', ar: '' } })
  title: { en: string; ar: string };

  @Prop({ type: { en: String, ar: String }, default: { en: '', ar: '' } })
  subtitle: { en: string; ar: string };

  @Prop({ default: '' })
  link: string;

  @Prop({ type: Types.ObjectId, ref: 'Product', default: null })
  productId?: Types.ObjectId | null;

  @Prop({ type: Types.ObjectId, ref: 'Category', default: null })
  categoryId?: Types.ObjectId | null;

  @Prop({ enum: AD_PLACEMENTS, default: 'home' })
  placement: AdPlacement;

  @Prop({ default: true })
  active: boolean;

  @Prop({ default: 0 })
  sortOrder: number;
}

export const AdSchema = SchemaFactory.createForClass(Ad);
AdSchema.index({ active: 1, placement: 1, sortOrder: 1 });
