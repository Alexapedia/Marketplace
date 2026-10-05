import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { USER_ROLES } from '../common/constants';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, lowercase: true, trim: true })
  email: string;

  @Prop({ select: false })
  passwordHash?: string;

  @Prop()
  phone?: string;

  @Prop()
  avatar?: string;

  @Prop({ required: true, enum: USER_ROLES, default: 'customer' })
  role: string;

  @Prop({ enum: ['active', 'blocked', 'deleted'], default: 'active' })
  status: string;

  @Prop()
  deletedAt?: Date;

  @Prop({ enum: ['en', 'ar'], default: 'en' })
  language: string;

  @Prop({ enum: ['light', 'dark', 'system'], default: 'system' })
  theme: string;

  @Prop({ sparse: true })
  firebaseUid?: string;

  @Prop({ type: [String], default: [] })
  fcmTokens: string[];

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

  @Prop()
  tenantId?: string;

  createdAt?: Date;
  updatedAt?: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete (ret as { passwordHash?: string }).passwordHash;
    delete (ret as { totpSecret?: string }).totpSecret;
    delete (ret as { backupCodeHashes?: string[] }).backupCodeHashes;
    return ret;
  },
});
