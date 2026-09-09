import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  Notification,
  NotificationDocument,
} from '../schemas/notification.schema';
import { User, UserDocument } from '../schemas/user.schema';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectModel(Notification.name)
    private readonly notificationModel: Model<NotificationDocument>,
    @InjectModel(User.name)
    private readonly userModel: Model<UserDocument>,
    private readonly config: ConfigService,
  ) {}

  async createAndOptionallyPush(params: {
    userId: string | Types.ObjectId;
    title: { en: string; ar: string };
    body: { en: string; ar: string };
    type: string;
    data?: Record<string, unknown>;
  }) {
    const doc = await this.notificationModel.create({
      userId: new Types.ObjectId(String(params.userId)),
      title: params.title,
      body: params.body,
      type: params.type,
      data: params.data,
    });

    const enabled = this.config.get<string>('FIREBASE_ENABLED') === 'true';
    if (enabled) {
      const user = await this.userModel
        .findById(params.userId)
        .select('fcmTokens')
        .lean();
      if (user?.fcmTokens?.length) {
        this.logger.debug(
          `FCM stub: would push to ${user.fcmTokens.length} token(s) for user ${params.userId}`,
        );
      }
    }

    return doc;
  }

  async findMine(userId: string, page: number, limit: number) {
    const filter = { userId: new Types.ObjectId(userId) };
    const [items, total] = await Promise.all([
      this.notificationModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit),
      this.notificationModel.countDocuments(filter),
    ]);
    return { items, total };
  }

  async markRead(userId: string, id: string) {
    return this.notificationModel.findOneAndUpdate(
      { _id: id, userId: new Types.ObjectId(userId) },
      { readAt: new Date() },
      { new: true },
    );
  }

  async sendToTargets(params: {
    title: { en: string; ar: string };
    body: { en: string; ar: string };
    target: 'all' | 'userIds';
    userIds?: string[];
    type?: string;
  }) {
    let userIds: string[] = params.userIds ?? [];
    if (params.target === 'all') {
      const users = await this.userModel.find({ status: 'active' }).select('_id');
      userIds = users.map((u) => String(u._id));
    }
    let sent = 0;
    for (const userId of userIds) {
      await this.createAndOptionallyPush({
        userId,
        title: params.title,
        body: params.body,
        type: params.type ?? 'broadcast',
      });
      sent += 1;
    }
    return { sent };
  }
}
