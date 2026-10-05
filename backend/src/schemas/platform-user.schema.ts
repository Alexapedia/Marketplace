import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type PlatformUserDocument = HydratedDocument<PlatformUser>;

@Schema({ timestamps: true })
export class PlatformUser {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ required: true, select: false })
  passwordHash: string;

  @Prop({ default: 'platform_owner' })
  role: string;

  @Prop({ enum: ['active', 'blocked'], default: 'active' })
  status: string;

  @Prop({ select: false })
  totpSecret?: string;

  @Prop({ default: false })
  totpEnabled: boolean;

  @Prop({ type: [String], default: [], select: false })
  backupCodeHashes: string[];

  @Prop({ default: 0 })
  failedLoginCount: number;

  @Prop()
  lockUntil?: Date;

  createdAt?: Date;
  updatedAt?: Date;
}

export const PlatformUserSchema = SchemaFactory.createForClass(PlatformUser);

PlatformUserSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete (ret as { passwordHash?: string }).passwordHash;
    delete (ret as { totpSecret?: string }).totpSecret;
    delete (ret as { backupCodeHashes?: string[] }).backupCodeHashes;
    return ret;
  },
});
