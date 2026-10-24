import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Visit, VisitDocument } from '../schemas/visit.schema';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectModel(Visit.name) private readonly visits: Model<VisitDocument>,
  ) {}

  async track(params: {
    platform: string;
    path?: string;
    sessionId?: string;
    userId?: string;
  }) {
    const platform = params.platform === 'website' ? 'website' : 'mobile';
    const since = new Date(Date.now() - 30 * 60 * 1000);
    if (params.sessionId) {
      const recent = await this.visits.findOne({
        platform,
        sessionId: params.sessionId,
        createdAt: { $gte: since },
      });
      if (recent) {
        return { tracked: false };
      }
    }
    await this.visits.create({
      platform,
      path: params.path,
      sessionId: params.sessionId,
      userId: params.userId
        ? new Types.ObjectId(params.userId)
        : undefined,
    });
    return { tracked: true };
  }

  async summary(from?: Date, to?: Date) {
    const range: Record<string, unknown> = {};
    if (from || to) {
      range.createdAt = {
        ...(from ? { $gte: from } : {}),
        ...(to ? { $lte: to } : {}),
      };
    }
    const [byPlatform, unique] = await Promise.all([
      this.visits.aggregate([
        { $match: range },
        { $group: { _id: '$platform', count: { $sum: 1 } } },
      ]),
      this.visits.aggregate([
        { $match: range },
        {
          $group: {
            _id: { platform: '$platform', sessionId: '$sessionId' },
          },
        },
        { $group: { _id: '$_id.platform', count: { $sum: 1 } } },
      ]),
    ]);
    const pick = (
      rows: Array<{ _id: string; count: number }>,
      key: string,
    ) => rows.find((r) => r._id === key)?.count ?? 0;
    return {
      visitsMobile: pick(byPlatform, 'mobile'),
      visitsWebsite: pick(byPlatform, 'website'),
      uniqueMobile: pick(unique, 'mobile'),
      uniqueWebsite: pick(unique, 'website'),
    };
  }
}
