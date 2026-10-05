import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
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
    private readonly firebase: FirebaseAdminService,
  ) {}

  async createAndOptionallyPush(params: {
    userId: string | Types.ObjectId;
    title: { en: string; ar: string };
    body: { en: string; ar: string };
    type: string;
    data?: Record<string, unknown>;
    batchId?: string;
  }) {
    const doc = await this.notificationModel.create({
      userId: new Types.ObjectId(String(params.userId)),
      title: params.title,
      body: params.body,
      type: params.type,
      data: params.data,
      batchId: params.batchId,
    });

    try {
      const user = await this.userModel
        .findById(params.userId)
        .select('fcmTokens language')
        .lean();
      const tokens = user?.fcmTokens ?? [];
      if (this.firebase.enabled && tokens.length) {
        const lang = user?.language === 'ar' ? 'ar' : 'en';
        const data = this.toStringMap({
          type: params.type,
          notificationId: String(doc._id),
          ...(params.data ?? {}),
        });
        const invalid = await this.firebase.sendToTokens(tokens, {
          title: params.title[lang] || params.title.en,
          body: params.body[lang] || params.body.en,
          data,
          clickPath: this.clickPath(params.type, params.data),
        });
        if (invalid.length) {
          await this.userModel.updateOne(
            { _id: params.userId },
            { $pull: { fcmTokens: { $in: invalid } } },
          );
        }
      }
    } catch (err) {
      this.logger.warn(`Push failed: ${(err as Error).message}`);
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

  async unreadCount(userId: string) {
    return this.notificationModel.countDocuments({
      userId: new Types.ObjectId(userId),
      $or: [{ readAt: { $exists: false } }, { readAt: null }],
    });
  }

  async notifyRoles(params: {
    roles: string[];
    title: { en: string; ar: string };
    body: { en: string; ar: string };
    type: string;
    data?: Record<string, unknown>;
  }) {
    const users = await this.userModel
      .find({ role: { $in: params.roles }, status: 'active' })
      .select('_id')
      .lean();
    await Promise.all(
      users.map((user) =>
        this.createAndOptionallyPush({
          userId: String(user._id),
          title: params.title,
          body: params.body,
          type: params.type,
          data: params.data,
        }),
      ),
    );
    return { sent: users.length };
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
      const users = await this.userModel
        .find({ status: 'active', role: 'customer' })
        .select('_id');
      userIds = users.map((u) => String(u._id));
    }
    let sent = 0;
    const batchId = new Types.ObjectId().toString();
    for (const userId of userIds) {
      await this.createAndOptionallyPush({
        userId,
        title: params.title,
        body: params.body,
        type: params.type ?? 'broadcast',
        batchId,
      });
      sent += 1;
    }
    return { sent, batchId };
  }

  async listAdmin(page: number, limit: number) {
    const match = { batchId: { $exists: true, $nin: [null, ''] } };
    const [items, totalGroups] = await Promise.all([
      this.notificationModel.aggregate([
        { $match: match },
        { $sort: { createdAt: -1 } },
        {
          $group: {
            _id: '$batchId',
            title: { $first: '$title' },
            body: { $first: '$body' },
            type: { $first: '$type' },
            createdAt: { $first: '$createdAt' },
            sent: { $sum: 1 },
          },
        },
        { $sort: { createdAt: -1 } },
        { $skip: (page - 1) * limit },
        { $limit: limit },
      ]),
      this.notificationModel.distinct('batchId', match),
    ]);
    return {
      data: items.map((row) => ({
        _id: row._id,
        title: row.title,
        body: row.body,
        type: row.type,
        createdAt: row.createdAt,
        sent: row.sent,
      })),
      meta: {
        page,
        limit,
        total: totalGroups.length,
        totalPages: Math.max(1, Math.ceil(totalGroups.length / limit)),
      },
    };
  }

  private clickPath(type: string, data?: Record<string, unknown>) {
    const orderId = String(data?.orderId ?? '');
    const customOrderId = String(data?.customOrderId ?? '');
    if (type === 'new_order') return '/orders';
    if (type === 'new_custom_order') return '/custom-orders';
    if (type === 'order_status') {
      return orderId ? `/orders/${orderId}` : '/orders';
    }
    if (
      type === 'custom_order_proposal' ||
      type === 'custom_order_confirmed'
    ) {
      return customOrderId ? `/custom/${customOrderId}` : '/custom';
    }
    return '/notifications';
  }

  private toStringMap(data: Record<string, unknown>) {
    const out: Record<string, string> = {};
    for (const [key, value] of Object.entries(data)) {
      if (value == null) continue;
      out[key] = String(value);
    }
    return out;
  }
}
