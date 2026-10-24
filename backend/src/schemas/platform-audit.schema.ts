import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, SchemaTypes, Types } from 'mongoose';

export type PlatformAuditDocument = HydratedDocument<PlatformAudit>;

@Schema({ timestamps: true })
export class PlatformAudit {
  @Prop({ type: Types.ObjectId, ref: 'PlatformUser', required: true })
  actorId: Types.ObjectId;

  @Prop({ required: true })
  action: string;

  @Prop()
  tenantId?: string;

  @Prop({ type: SchemaTypes.Mixed })
  meta?: unknown;

  @Prop()
  ip?: string;

  createdAt?: Date;
}

export const PlatformAuditSchema = SchemaFactory.createForClass(PlatformAudit);
PlatformAuditSchema.index({ createdAt: -1 });
PlatformAuditSchema.index({ tenantId: 1, createdAt: -1 });
