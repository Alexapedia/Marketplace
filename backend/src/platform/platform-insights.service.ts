import { Injectable } from '@nestjs/common';
import { InjectConnection, InjectModel } from '@nestjs/mongoose';
import { Connection, Model } from 'mongoose';
import { CustomOrder, CustomOrderDocument } from '../schemas/custom-order.schema';
import { Order, OrderDocument } from '../schemas/order.schema';
import { PlatformEvent, PlatformEventDocument } from '../schemas/platform-event.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { Tenant, TenantDocument } from '../schemas/tenant.schema';
import { User, UserDocument } from '../schemas/user.schema';
import { Visit, VisitDocument } from '../schemas/visit.schema';
import { TenantContext } from '../tenant/tenant.context';
import { PlatformTelemetryService } from './platform-telemetry.service';

const CANCELLED = new Set(['cancelled']);

function dayKey(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function daysBack(n: number): string[] {
  const out: string[] = [];
  const now = new Date();
  for (let i = n - 1; i >= 0; i--) {
    const d = new Date(now);
    d.setUTCDate(d.getUTCDate() - i);
    out.push(dayKey(d));
  }
  return out;
}

@Injectable()
export class PlatformInsightsService {
  constructor(
    @InjectConnection() private readonly connection: Connection,
    @InjectModel(Tenant.name) private readonly tenants: Model<TenantDocument>,
    @InjectModel(User.name) private readonly users: Model<UserDocument>,
    @InjectModel(Product.name) private readonly products: Model<ProductDocument>,
    @InjectModel(Order.name) private readonly orders: Model<OrderDocument>,
    @InjectModel(CustomOrder.name)
    private readonly customOrders: Model<CustomOrderDocument>,
    @InjectModel(Visit.name) private readonly visits: Model<VisitDocument>,
    @InjectModel(PlatformEvent.name)
    private readonly events: Model<PlatformEventDocument>,
    private readonly telemetry: PlatformTelemetryService,
  ) {}

  async overview() {
    return TenantContext.run({ kind: 'platform' }, async () => {
      const from7 = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      const [
        tenantCount,
        active,
        suspended,
        customers,
        staff,
        products,
        orders,
        customOrders,
        revenue,
        revenue7d,
        orders7d,
        ordersOpen,
        visits,
        issueCounts,
        seriesOrders,
        top,
        recentIssues,
        tenantDocs,
      ] = await Promise.all([
        this.tenants.countDocuments(),
        this.tenants.countDocuments({ status: 'active' }),
        this.tenants.countDocuments({ status: 'suspended' }),
        this.users.countDocuments({ role: 'customer', status: { $ne: 'deleted' } }),
        this.users.countDocuments({ role: { $ne: 'customer' }, status: { $ne: 'deleted' } }),
        this.products.countDocuments(),
        this.orders.countDocuments(),
        this.customOrders.countDocuments(),
        this.sumRevenue(),
        this.sumRevenue(from7),
        this.orders.countDocuments({ createdAt: { $gte: from7 } }),
        this.orders.countDocuments({
          orderStatus: { $nin: ['cancelled', 'delivered', 'completed'] },
        }),
        this.visits.aggregate([{ $group: { _id: '$platform', count: { $sum: 1 } } }]),
        this.telemetry.counts(),
        this.orders.aggregate([
          { $match: { createdAt: { $gte: from7 } } },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
              orders: { $sum: 1 },
              revenue: {
                $sum: {
                  $cond: [{ $in: ['$orderStatus', ['cancelled']] }, 0, '$total'],
                },
              },
            },
          },
        ]),
        this.orders.aggregate([
          {
            $group: {
              _id: '$tenantId',
              orders: { $sum: 1 },
              revenue: {
                $sum: {
                  $cond: [{ $in: ['$orderStatus', ['cancelled']] }, 0, '$total'],
                },
              },
            },
          },
          { $sort: { revenue: -1 } },
          { $limit: 6 },
        ]),
        this.events.find({ status: 'open' }).sort({ lastSeen: -1 }).limit(6).lean(),
        this.tenants.find().lean(),
      ]);

      const pickVisit = (key: string) =>
        (visits as Array<{ _id: string; count: number }>).find((r) => r._id === key)?.count ?? 0;

      let websiteOff = 0;
      let adminOff = 0;
      let mobileOff = 0;
      for (const t of tenantDocs) {
        if (t.channels?.website === false) websiteOff += 1;
        if (t.channels?.admin === false) adminOff += 1;
        if (t.channels?.mobile === false) mobileOff += 1;
      }

      const names = new Map(tenantDocs.map((t) => [String(t._id), t.name]));
      const keys = daysBack(7);
      const seriesMap = new Map(
        (seriesOrders as Array<{ _id: string; orders: number; revenue: number }>).map((r) => [
          r._id,
          r,
        ]),
      );
      const series7 = keys.map((day) => ({
        day,
        orders: seriesMap.get(day)?.orders ?? 0,
        revenue: seriesMap.get(day)?.revenue ?? 0,
      }));

      return {
        tenantCount,
        active,
        suspended,
        customers,
        staff,
        products,
        orders,
        customOrders,
        revenue,
        revenue7d,
        orders7d,
        ordersOpen,
        visitsWebsite: pickVisit('website'),
        visitsMobile: pickVisit('mobile'),
        openIssues: issueCounts.open,
        crashes24h: issueCounts.crashes24h,
        channelsOff: { website: websiteOff, admin: adminOff, mobile: mobileOff },
        series7,
        topTenants: (
          top as Array<{ _id: string; orders: number; revenue: number }>
        ).map((row) => ({
          id: row._id,
          name: names.get(String(row._id)) || row._id || 'Unknown',
          orders: row.orders,
          revenue: row.revenue,
        })),
        recentIssues: recentIssues.map((e) => ({
          id: String(e._id),
          kind: e.kind,
          channel: e.channel,
          message: e.message,
          count: e.count,
          lastSeen: e.lastSeen,
          tenantId: e.tenantId,
        })),
        db: this.connection.readyState === 1 ? 'up' : 'down',
      };
    });
  }

  async reports() {
    return TenantContext.run({ kind: 'platform' }, async () => {
      const from14 = new Date(Date.now() - 14 * 24 * 60 * 60 * 1000);
      const keys = daysBack(14);
      const [
        orderSeries,
        visitSeries,
        crashSeries,
        ordersByStatus,
        revenueByTenant,
        visitsByPlatform,
        issuesByChannel,
        tenantDocs,
      ] = await Promise.all([
        this.orders.aggregate([
          { $match: { createdAt: { $gte: from14 } } },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
              orders: { $sum: 1 },
              revenue: {
                $sum: {
                  $cond: [{ $in: ['$orderStatus', ['cancelled']] }, 0, '$total'],
                },
              },
            },
          },
        ]),
        this.visits.aggregate([
          { $match: { createdAt: { $gte: from14 } } },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
              visits: { $sum: 1 },
            },
          },
        ]),
        this.events.aggregate([
          { $match: { lastSeen: { $gte: from14 }, kind: { $in: ['crash', 'error'] } } },
          {
            $group: {
              _id: { $dateToString: { format: '%Y-%m-%d', date: '$lastSeen' } },
              crashes: { $sum: '$count' },
            },
          },
        ]),
        this.orders.aggregate([
          { $group: { _id: '$orderStatus', count: { $sum: 1 } } },
        ]),
        this.orders.aggregate([
          {
            $group: {
              _id: '$tenantId',
              orders: { $sum: 1 },
              revenue: {
                $sum: {
                  $cond: [{ $in: ['$orderStatus', ['cancelled']] }, 0, '$total'],
                },
              },
            },
          },
          { $sort: { revenue: -1 } },
          { $limit: 12 },
        ]),
        this.visits.aggregate([{ $group: { _id: '$platform', count: { $sum: 1 } } }]),
        this.events.aggregate([
          { $match: { status: 'open' } },
          { $group: { _id: '$channel', count: { $sum: 1 } } },
        ]),
        this.tenants.find().lean(),
      ]);

      const oMap = new Map(
        (orderSeries as Array<{ _id: string; orders: number; revenue: number }>).map((r) => [
          r._id,
          r,
        ]),
      );
      const vMap = new Map(
        (visitSeries as Array<{ _id: string; visits: number }>).map((r) => [r._id, r.visits]),
      );
      const cMap = new Map(
        (crashSeries as Array<{ _id: string; crashes: number }>).map((r) => [r._id, r.crashes]),
      );
      const names = new Map(tenantDocs.map((t) => [String(t._id), t.name]));

      return {
        series14: keys.map((day) => ({
          day,
          orders: oMap.get(day)?.orders ?? 0,
          revenue: oMap.get(day)?.revenue ?? 0,
          visits: vMap.get(day) ?? 0,
          crashes: cMap.get(day) ?? 0,
        })),
        ordersByStatus: (
          ordersByStatus as Array<{ _id: string; count: number }>
        ).map((r) => ({ status: r._id || 'unknown', count: r.count })),
        revenueByTenant: (
          revenueByTenant as Array<{ _id: string; orders: number; revenue: number }>
        ).map((r) => ({
          id: r._id,
          name: names.get(String(r._id)) || r._id || 'Unknown',
          orders: r.orders,
          revenue: r.revenue,
        })),
        visitsByPlatform: (
          visitsByPlatform as Array<{ _id: string; count: number }>
        ).map((r) => ({ platform: r._id, count: r.count })),
        issuesByChannel: (
          issuesByChannel as Array<{ _id: string; count: number }>
        ).map((r) => ({ channel: r._id, count: r.count })),
        channelMatrix: tenantDocs.map((t) => ({
          id: String(t._id),
          name: t.name,
          status: t.status,
          channels: {
            website: t.channels?.website !== false,
            admin: t.channels?.admin !== false,
            mobile: t.channels?.mobile !== false,
          },
        })),
      };
    });
  }

  private async sumRevenue(from?: Date) {
    const match: Record<string, unknown> = {
      orderStatus: { $nin: Array.from(CANCELLED) },
    };
    if (from) match.createdAt = { $gte: from };
    const rows = await this.orders.aggregate([
      { $match: match },
      { $group: { _id: null, total: { $sum: '$total' } } },
    ]);
    return Number(rows[0]?.total ?? 0);
  }
}
