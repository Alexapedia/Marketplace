import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes } from 'mongoose';

export type AppConfigDocument = HydratedDocument<AppConfig>;

@Schema({ _id: false })
export class StoreVersion {
  @Prop({ required: true })
  latest: string;

  @Prop({ required: true })
  minimum: string;

  @Prop({ default: false })
  forceUpdate: boolean;

  @Prop()
  storeUrl?: string;

  @Prop({ type: { en: String, ar: String }, default: { en: '', ar: '' } })
  message: { en: string; ar: string };
}

export const StoreVersionSchema = SchemaFactory.createForClass(StoreVersion);

@Schema({ timestamps: true })
export class AppConfig {
  @Prop({ unique: true, default: 'global' })
  key: string;

  @Prop({ type: [SchemaTypes.Mixed], default: [] })
  banners: Record<string, unknown>[];

  @Prop({ type: [SchemaTypes.Mixed], default: [] })
  onboarding: Record<string, unknown>[];

  @Prop({
    type: {
      android: { type: StoreVersionSchema },
      ios: { type: StoreVersionSchema },
    },
    default: {},
  })
  version: { android?: StoreVersion; ios?: StoreVersion };

  @Prop({ type: SchemaTypes.Mixed, default: {} })
  settings: Record<string, unknown>;
}

export const AppConfigSchema = SchemaFactory.createForClass(AppConfig);
