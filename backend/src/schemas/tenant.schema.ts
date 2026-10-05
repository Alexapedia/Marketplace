import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type TenantDocument = HydratedDocument<Tenant>;

export type TenantStatus = 'active' | 'suspended';
export type TenantDomainChannel = 'website' | 'admin';

@Schema({ _id: false })
export class TenantDomain {
  @Prop({ required: true, lowercase: true, trim: true })
  host: string;

  @Prop({ required: true, enum: ['website', 'admin'] })
  channel: TenantDomainChannel;
}

@Schema({ _id: false })
export class TenantChannels {
  @Prop({ default: true })
  website: boolean;

  @Prop({ default: true })
  admin: boolean;

  @Prop({ default: true })
  mobile: boolean;
}

@Schema({ _id: false })
export class TenantBranding {
  @Prop({ default: 'Store' })
  name: string;

  @Prop({ default: '#071345' })
  primary: string;

  @Prop({ default: '#c9a45c' })
  accent: string;

  @Prop({ default: '' })
  logo: string;

  @Prop({ default: '' })
  logoDark: string;

  @Prop({ default: '' })
  favicon: string;

  @Prop({ default: '' })
  splash: string;
}

@Schema({ timestamps: true })
export class Tenant {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  slug: string;

  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ enum: ['active', 'suspended'], default: 'active' })
  status: TenantStatus;

  @Prop({ type: [TenantDomain], default: [] })
  domains: TenantDomain[];

  @Prop({ type: TenantChannels, default: () => ({}) })
  channels: TenantChannels;

  @Prop({ type: TenantBranding, default: () => ({}) })
  branding: TenantBranding;

  @Prop({ default: 'SAR' })
  currency: string;

  createdAt?: Date;
  updatedAt?: Date;
}

export const TenantSchema = SchemaFactory.createForClass(Tenant);
TenantSchema.index({ 'domains.host': 1 }, { unique: true, sparse: true });
