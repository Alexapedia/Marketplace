import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';
import { USER_ROLES } from '../common/constants';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true })
  name: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ select: false })
  passwordHash?: string;

  @Prop()
  phone?: string;

  @Prop()
  avatar?: string;

  @Prop({ required: true, enum: USER_ROLES, default: 'customer' })
  role: string;

  @Prop({ enum: ['active', 'blocked'], default: 'active' })
  status: string;

  @Prop({ enum: ['en', 'ar'], default: 'en' })
  language: string;

  @Prop({ enum: ['light', 'dark', 'system'], default: 'system' })
  theme: string;

  @Prop({ sparse: true, unique: true })
  firebaseUid?: string;

  @Prop({ type: [String], default: [] })
  fcmTokens: string[];

  createdAt?: Date;
  updatedAt?: Date;
}

export const UserSchema = SchemaFactory.createForClass(User);

UserSchema.set('toJSON', {
  transform: (_doc, ret) => {
    delete (ret as { passwordHash?: string }).passwordHash;
    return ret;
  },
});
