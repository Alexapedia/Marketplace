import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type CategoryDocument = HydratedDocument<Category>;

@Schema({ timestamps: true })
export class Category {
  @Prop({ type: { en: String, ar: String }, required: true })
  names: { en: string; ar: string };

  @Prop({ type: Types.ObjectId, ref: 'Category', default: null })
  parentId?: Types.ObjectId | null;

  @Prop()
  image?: string;

  @Prop({ enum: ['standard', 'custom', 'both'], default: 'standard' })
  type: string;

  @Prop({ enum: ['published', 'unpublished'], default: 'published' })
  status: string;

  @Prop({ default: 0 })
  sortOrder: number;
}

export const CategorySchema = SchemaFactory.createForClass(Category);
