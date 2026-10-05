import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { createHash } from 'crypto';
import { Model } from 'mongoose';
import {
  PlatformEvent,
  PlatformEventDocument,
} from '../schemas/platform-event.schema';
import { TenantContext } from '../tenant/tenant.context';

export type TelemetryKind = 'crash' | 'error' | 'issue';
export type TelemetryChannel = 'website' | 'admin' | 'mobile' | 'holder' | 'api';

@Injectable()
export class PlatformTelemetryService {
  constructor(
    @InjectModel(PlatformEvent.name)
    private readonly events: Model<PlatformEventDocument>,
  ) {}

  async ingest(input: {
    kind?: string;
    channel?: string;
    message?: string;
    stack?: string;
    url?: string;
    userAgent?: string;
    tenantId?: string;
    meta?: unknown;
  }) {
    const message = String(input.message || 'Unknown error').slice(0, 500);
    const stack = input.stack ? String(input.stack).slice(0, 4000) : undefined;
    const kind = this.kind(input.kind);
    const channel = this.channel(input.channel);
    const tenantId =
      input.tenantId ||
      (TenantContext.get().kind === 'tenant' ? TenantContext.tenantId() : undefined);
    const firstLine = (stack || '').split('\n')[0] || '';
    const fingerprint = createHash('sha256')
      .update(`${kind}|${channel}|${message}|${firstLine}`)
      .digest('hex')
      .slice(0, 32);
    const now = new Date();
    await this.events.findOneAndUpdate(
      { fingerprint },
      {
        $set: {
          kind,
          channel,
          tenantId,
          message,
          stack,
          url: input.url ? String(input.url).slice(0, 500) : undefined,
          userAgent: input.userAgent ? String(input.userAgent).slice(0, 300) : undefined,
          meta: input.meta,
          lastSeen: now,
          status: 'open',
        },
        $inc: { count: 1 },
        $setOnInsert: { fingerprint, firstSeen: now },
      },
      { upsert: true },
    );
    return { recorded: true };
  }

  async list(filter: { status?: string; channel?: string; tenantId?: string }) {
    const q: Record<string, unknown> = {};
    if (filter.status === 'open' || filter.status === 'resolved') {
      q.status = filter.status;
    }
    if (filter.channel) q.channel = filter.channel;
    if (filter.tenantId) q.tenantId = filter.tenantId;
    const rows = await this.events.find(q).sort({ lastSeen: -1 }).limit(200).lean();
    return rows.map((e) => ({
      ...e,
      id: String(e._id),
    }));
  }

  async resolve(id: string) {
    const doc = await this.events.findByIdAndUpdate(
      id,
      { $set: { status: 'resolved' } },
      { new: true },
    );
    return { resolved: !!doc };
  }

  async counts() {
    const dayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const [open, crashes24h, byChannel] = await Promise.all([
      this.events.countDocuments({ status: 'open' }),
      this.events.countDocuments({
        kind: 'crash',
        lastSeen: { $gte: dayAgo },
      }),
      this.events.aggregate([
        { $match: { status: 'open' } },
        { $group: { _id: '$channel', count: { $sum: 1 } } },
      ]),
    ]);
    return { open, crashes24h, byChannel };
  }

  private kind(raw?: string): TelemetryKind {
    if (raw === 'crash' || raw === 'issue') return raw;
    return 'error';
  }

  private channel(raw?: string): TelemetryChannel {
    const v = String(raw || '').toLowerCase();
    if (v === 'website' || v === 'admin' || v === 'mobile' || v === 'holder' || v === 'api') {
      return v;
    }
    const ctx = TenantContext.get().channel;
    if (ctx === 'website' || ctx === 'admin' || ctx === 'mobile') return ctx;
    return 'api';
  }
}
