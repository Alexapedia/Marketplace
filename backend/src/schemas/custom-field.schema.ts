import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';

export type CustomFieldDocument = HydratedDocument<CustomField>;

@Schema({ timestamps: true })
export class CustomField {
  @Prop({ type: Types.ObjectId, ref: 'Category', required: true })
  categoryId: Types.ObjectId;

  @Prop({ type: { en: String, ar: String }, required: true })
  labels: { en: string; ar: string };

  @Prop({
    enum: [
      'text',
      'number',
      'dropdown',
      'multi_select',
      'boolean',
      'size',
      'color',
      'image',
      'textarea',
    ],
    required: true,
  })
  fieldType: string;

  @Prop({ default: false })
  required: boolean;

  @Prop({ type: [String], default: [] })
  options: string[];

  @Prop({ default: 0 })
  sortOrder: number;

  @Prop({ enum: ['published', 'unpublished'], default: 'published' })
  status: string;
}

export const CustomFieldSchema = SchemaFactory.createForClass(CustomField);
