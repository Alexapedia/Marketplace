import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes, Types } from 'mongoose';

export type ProductDocument = HydratedDocument<Product>;

@Schema({ _id: true })
export class ProductVariant {
  @Prop()
  sku?: string;

  @Prop()
  name?: string;

  @Prop()
  price?: number;

  @Prop({ default: 0 })
  stock?: number;

  @Prop({ type: SchemaTypes.Mixed })
  attributes?: Record<string, unknown>;
}

export const ProductVariantSchema = SchemaFactory.createForClass(ProductVariant);

@Schema({ timestamps: true })
export class Product {
  @Prop({ type: Types.ObjectId, ref: 'Category', required: true })
  categoryId: Types.ObjectId;

  @Prop({ type: { en: String, ar: String }, required: true })
  names: { en: string; ar: string };

  @Prop({ type: { en: String, ar: String }, default: { en: '', ar: '' } })
  descriptions: { en: string; ar: string };

  @Prop({ type: [String], default: [] })
  images: string[];

  @Prop({ required: true, min: 0 })
  price: number;

  @Prop({ min: 0 })
  salePrice?: number;

  @Prop({ default: 0 })
  stock: number;

  @Prop({ default: 0 })
  ratingAvg: number;

  @Prop({ default: 0 })
  ratingCount: number;

  @Prop({ type: [ProductVariantSchema], default: [] })
  variants: ProductVariant[];

  @Prop({ type: SchemaTypes.Mixed })
  attributes?: Record<string, unknown>;

  @Prop()
  gender?: string;

  @Prop({ type: [String], default: [] })
  sizes: string[];

  @Prop({
    type: {
      featured: { type: Boolean, default: false },
      newArrival: { type: Boolean, default: false },
      bestSeller: { type: Boolean, default: false },
    },
    default: {},
  })
  flags: { featured: boolean; newArrival: boolean; bestSeller: boolean };

  @Prop({ default: 0 })
  sortOrder: number;

  @Prop({
    enum: ['published', 'unpublished', 'archived'],
    default: 'published',
  })
  status: string;

  @Prop({ type: [Types.ObjectId], ref: 'Product', default: [] })
  relatedProductIds: Types.ObjectId[];
}

export const ProductSchema = SchemaFactory.createForClass(Product);
