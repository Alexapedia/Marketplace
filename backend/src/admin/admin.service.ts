import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Model } from 'mongoose';
import { STAFF_ROLES } from '../common/constants';
import { paginationMeta } from '../common/dto/pagination.dto';
import { AuditLog, AuditLogDocument } from '../schemas/audit-log.schema';
import {
  Conversation,
  ConversationDocument,
} from '../schemas/conversation.schema';
import { CustomOrder, CustomOrderDocument } from '../schemas/custom-order.schema';
import { Order, OrderDocument } from '../schemas/order.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { Role, RoleDocument } from '../schemas/role.schema';
import { User, UserDocument } from '../schemas/user.schema';
import { AnalyticsService } from '../analytics/analytics.service';

@Injectable()
export class AdminService {
  constructor(
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
    @InjectModel(CustomOrder.name)
    private readonly customModel: Model<CustomOrderDocument>,
    @InjectModel(Conversation.name)
    private readonly conversationModel: Model<ConversationDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    @InjectModel(Role.name) private readonly roleModel: Model<RoleDocument>,
    @InjectModel(AuditLog.name)
    private readonly auditModel: Model<AuditLogDocument>,
    private readonly analytics: AnalyticsService,
  ) {}

  async dashboard() {
    const since = new Date();
    since.setDate(since.getDate() - 30);
    const dayStart = new Date();
    dayStart.setHours(0, 0, 0, 0);
    const seriesFrom = new Date(dayStart);
    seriesFrom.setDate(seriesFrom.getDate() - 13);
    const weekFrom = new Date(dayStart);
    weekFrom.setDate(weekFrom.getDate() - 6);
    const prevWeekFrom = new Date(dayStart);
    prevWeekFrom.setDate(prevWeekFrom.getDate() - 13);

    const [
      orders,
      pendingCustom,
      unreadChats,
      products,
      customers,
      newCustomers,
      revenueAgg,
      statusAgg,
      customStatusAgg,
      userStatusAgg,
      productStatusAgg,
      channelAgg,
      topProducts,
      lowStock,
      visits,
      dailyAgg,
      thisWeekAgg,
      prevWeekAgg,
    ] = await Promise.all([
      this.orderModel.countDocuments(),
      this.customModel.countDocuments({
        status: {
          $in: [
            'submitted',
            'under_review',
            'need_more_details',
            'quote_sent',
            'waiting_confirmation',
          ],
        },
      }),
      this.conversationModel.countDocuments({ unreadByStaff: { $gt: 0 } }),
      this.productModel.countDocuments(),
      this.userModel.countDocuments({ role: 'customer' }),
      this.userModel.countDocuments({
        role: 'customer',
        createdAt: { $gte: since },
      }),
      this.orderModel.aggregate<{ total: number; delivery: number }>([
        { $match: { orderStatus: { $in: ['completed', 'delivered'] } } },
        {
          $group: {
            _id: null,
            total: { $sum: '$total' },
            delivery: { $sum: '$deliveryFee' },
          },
        },
      ]),
      this.orderModel.aggregate<{ _id: string; count: number; revenue: number }>([
        {
          $group: {
            _id: '$orderStatus',
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
      this.customModel.aggregate<{ _id: string; count: number }>([
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
      this.userModel.aggregate<{ _id: string; count: number }>([
        { $match: { role: 'customer' } },
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
      this.productModel.aggregate<{ _id: string; count: number }>([
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
      this.orderModel.aggregate<{
        _id: string;
        count: number;
        revenue: number;
      }>([
        {
          $group: {
            _id: { $ifNull: ['$channel', 'mobile'] },
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
      this.orderModel.aggregate([
        { $match: { orderStatus: { $in: ['completed', 'delivered'] } } },
        { $unwind: '$items' },
        {
          $group: {
            _id: { $ifNull: ['$items.productId', '$items.nameSnapshot'] },
            name: { $first: '$items.nameSnapshot' },
            quantity: { $sum: '$items.quantity' },
            revenue: {
              $sum: { $multiply: ['$items.unitPrice', '$items.quantity'] },
            },
          },
        },
        { $sort: { revenue: -1 } },
        { $limit: 8 },
      ]),
      this.productModel.countDocuments({
        status: 'published',
        stock: { $lte: 5 },
      }),
      this.analytics.summary(since),
      this.orderModel.aggregate<{ _id: string; count: number; revenue: number }>([
        { $match: { createdAt: { $gte: seriesFrom } } },
        {
          $group: {
            _id: {
              $dateToString: { format: '%Y-%m-%d', date: '$createdAt' },
            },
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
        { $sort: { _id: 1 } },
      ]),
      this.orderModel.aggregate<{ count: number; revenue: number }>([
        { $match: { createdAt: { $gte: weekFrom } } },
        {
          $group: {
            _id: null,
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
      this.orderModel.aggregate<{ count: number; revenue: number }>([
        {
          $match: {
            createdAt: { $gte: prevWeekFrom, $lt: weekFrom },
          },
        },
        {
          $group: {
            _id: null,
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
    ]);

    const pick = (
      rows: Array<{ _id: string; count: number }>,
      key: string,
    ) => rows.find((r) => r._id === key)?.count ?? 0;

    return {
      orders,
      pendingCustom,
      unreadChats,
      products,
      customers,
      newCustomers,
      revenue: revenueAgg[0]?.total ?? 0,
      deliveryFees: revenueAgg[0]?.delivery ?? 0,
      profit: (revenueAgg[0]?.total ?? 0) - (revenueAgg[0]?.delivery ?? 0),
      lowStock,
      activeCustomers: pick(userStatusAgg, 'active'),
      inactiveCustomers: pick(userStatusAgg, 'blocked'),
      publishedProducts: pick(productStatusAgg, 'published'),
      unpublishedProducts: pick(productStatusAgg, 'unpublished'),
      ordersByStatus: statusAgg.map((row) => ({
        status: row._id || 'unknown',
        count: row.count,
        revenue: row.revenue,
      })),
      customOrdersByStatus: customStatusAgg.map((row) => ({
        status: row._id || 'unknown',
        count: row.count,
      })),
      ordersByChannel: channelAgg.map((row) => ({
        channel: row._id || 'mobile',
        count: row.count,
        revenue: row.revenue,
      })),
      topProducts: (
        topProducts as Array<{
          _id?: unknown;
          name?: string;
          quantity?: number;
          revenue?: number;
        }>
      ).map((row) => ({
        productId: typeof row._id === 'object' ? String(row._id) : undefined,
        name: row.name || (typeof row._id === 'string' ? row._id : ''),
        quantity: row.quantity,
        revenue: row.revenue,
      })),
      visits,
      series: this.fillDailySeries(seriesFrom, dailyAgg),
      trend: {
        orders:
          (thisWeekAgg[0]?.count ?? 0) - (prevWeekAgg[0]?.count ?? 0),
        revenue:
          (thisWeekAgg[0]?.revenue ?? 0) - (prevWeekAgg[0]?.revenue ?? 0),
        thisWeekOrders: thisWeekAgg[0]?.count ?? 0,
        prevWeekOrders: prevWeekAgg[0]?.count ?? 0,
      },
    };
  }

  private fillDailySeries(
    from: Date,
    rows: Array<{ _id: string; count: number; revenue: number }>,
  ) {
    const map = new Map(rows.map((row) => [row._id, row]));
    const series: Array<{ date: string; orders: number; revenue: number }> = [];
    const cursor = new Date(from);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    while (cursor <= today) {
      const key = cursor.toISOString().slice(0, 10);
      const hit = map.get(key);
      series.push({
        date: key,
        orders: hit?.count ?? 0,
        revenue: hit?.revenue ?? 0,
      });
      cursor.setDate(cursor.getDate() + 1);
    }
    return series;
  }

  async reports(from?: string, to?: string) {
    const range: Record<string, unknown> = {};
    if (from || to) {
      range.createdAt = {};
      if (from) {
        (range.createdAt as Record<string, Date>).$gte = new Date(from);
      }
      if (to) {
        const end = new Date(to);
        end.setHours(23, 59, 59, 999);
        (range.createdAt as Record<string, Date>).$lte = end;
      }
    }
    const fromDate = from ? new Date(from) : undefined;
    const toDate = to
      ? (() => {
          const end = new Date(to);
          end.setHours(23, 59, 59, 999);
          return end;
        })()
      : undefined;

    const [
      ordersByStatus,
      topProducts,
      customStats,
      rejectedReasons,
      money,
      lost,
      channelAgg,
      buyers,
      visits,
      customers,
    ] = await Promise.all([
      this.orderModel.aggregate([
        { $match: range },
        {
          $group: {
            _id: '$orderStatus',
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
      this.orderModel.aggregate([
        { $match: { ...range, orderStatus: { $in: ['completed', 'delivered'] } } },
        { $unwind: '$items' },
        {
          $group: {
            _id: { $ifNull: ['$items.productId', '$items.nameSnapshot'] },
            name: { $first: '$items.nameSnapshot' },
            quantity: { $sum: '$items.quantity' },
            revenue: {
              $sum: { $multiply: ['$items.unitPrice', '$items.quantity'] },
            },
          },
        },
        { $sort: { revenue: -1 } },
        { $limit: 12 },
      ]),
      this.customModel.aggregate([
        { $match: range },
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),
      this.orderModel.aggregate([
        { $match: { ...range, orderStatus: 'rejected' } },
        { $group: { _id: '$rejectionReason', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
      ]),
      this.orderModel.aggregate<{
        revenue: number;
        delivery: number;
        orders: number;
      }>([
        {
          $match: {
            ...range,
            orderStatus: { $in: ['completed', 'delivered'] },
          },
        },
        {
          $group: {
            _id: null,
            revenue: { $sum: '$total' },
            delivery: { $sum: '$deliveryFee' },
            orders: { $sum: 1 },
          },
        },
      ]),
      this.orderModel.aggregate<{ lost: number; count: number }>([
        {
          $match: {
            ...range,
            orderStatus: { $in: ['cancelled', 'rejected'] },
          },
        },
        {
          $group: {
            _id: null,
            lost: { $sum: '$total' },
            count: { $sum: 1 },
          },
        },
      ]),
      this.orderModel.aggregate([
        { $match: range },
        {
          $group: {
            _id: { $ifNull: ['$channel', 'mobile'] },
            count: { $sum: 1 },
            revenue: { $sum: '$total' },
          },
        },
      ]),
      this.orderModel.aggregate([
        {
          $match: {
            ...range,
            orderStatus: { $in: ['completed', 'delivered'] },
          },
        },
        {
          $group: {
            _id: { $ifNull: ['$channel', 'mobile'] },
            buyers: { $addToSet: '$userId' },
            orders: { $sum: 1 },
          },
        },
        {
          $project: {
            channel: '$_id',
            orders: 1,
            buyers: { $size: '$buyers' },
          },
        },
      ]),
      this.analytics.summary(fromDate, toDate),
      this.userModel.countDocuments({
        role: 'customer',
        ...(range.createdAt ? { createdAt: range.createdAt } : {}),
      }),
    ]);

    const customOrders = (
      customStats as Array<{ _id: string; count: number }>
    ).reduce((sum, row) => sum + row.count, 0);
    const orderCount = (
      ordersByStatus as Array<{ _id: string; count: number }>
    ).reduce((sum, row) => sum + row.count, 0);
    const cancelled =
      (ordersByStatus as Array<{ _id: string; count: number }>).find(
        (r) => r._id === 'cancelled' || r._id === 'rejected',
      )?.count ?? 0;
    const gross = money[0]?.revenue ?? 0;
    const delivery = money[0]?.delivery ?? 0;
    const profit = gross - delivery;
    const lostSales = lost[0]?.lost ?? 0;
    const mappedTop = (
      topProducts as Array<{
        _id?: unknown;
        name?: string;
        quantity?: number;
        revenue?: number;
      }>
    ).map((row) => ({
      productId: typeof row._id === 'object' ? String(row._id) : undefined,
      name: row.name || (typeof row._id === 'string' ? row._id : ''),
      quantity: row.quantity,
      revenue: row.revenue,
    }));
    const visitsTotal =
      (visits.visitsMobile ?? 0) + (visits.visitsWebsite ?? 0);
    const conversion =
      visitsTotal > 0 ? Number(((orderCount / visitsTotal) * 100).toFixed(2)) : 0;

    return {
      ordersByStatus,
      topProducts: mappedTop,
      customStats,
      rejectedReasons,
      visits,
      ordersByChannel: channelAgg,
      buyersByChannel: buyers,
      profitLoss: {
        grossRevenue: gross,
        deliveryCost: delivery,
        netProfit: profit,
        lostSales,
        lostCount: lost[0]?.count ?? 0,
      },
      totals: {
        orders: orderCount,
        revenue: gross,
        customOrders,
        customers,
        conversion,
      },
      insights: this.buildInsights({
        orderCount,
        cancelled: cancelled + (lost[0]?.count ?? 0),
        gross,
        mappedTop,
        customOrders,
        visits,
        conversion,
        channelAgg: channelAgg as Array<{
          _id: string;
          count: number;
          revenue: number;
        }>,
      }),
    };
  }

  private buildInsights(input: {
    orderCount: number;
    cancelled: number;
    gross: number;
    mappedTop: Array<{ name?: string; revenue?: number }>;
    customOrders: number;
    visits: {
      visitsMobile: number;
      visitsWebsite: number;
    };
    conversion: number;
    channelAgg: Array<{ _id: string; count: number; revenue: number }>;
  }) {
    const tips: Array<{
      severity: 'info' | 'warn' | 'ok';
      title: { en: string; ar: string };
      body: { en: string; ar: string };
    }> = [];
    const cancelRate =
      input.orderCount > 0 ? input.cancelled / input.orderCount : 0;
    if (cancelRate >= 0.15) {
      tips.push({
        severity: 'warn',
        title: {
          en: 'Too many cancelled / rejected orders',
          ar: 'نسبة الإلغاء والرفض مرتفعة',
        },
        body: {
          en: 'Review rejection reasons, confirm stock before accepting, and speed up first response. High cancel rates cut profit and trust.',
          ar: 'راجع أسباب الرفض، تأكد من المخزون قبل القبول، وسرّع أول رد. الإلغاء العالي يقلل المكسب والثقة.',
        },
      });
    }
    const topShare =
      input.gross > 0 && input.mappedTop[0]?.revenue
        ? input.mappedTop[0].revenue / input.gross
        : 0;
    if (topShare >= 0.4 && input.mappedTop[0]?.name) {
      tips.push({
        severity: 'info',
        title: {
          en: 'Sales are concentrated on one product',
          ar: 'المبيعات متمركزة على منتج واحد',
        },
        body: {
          en: `"${input.mappedTop[0].name}" drives most income. Bundle it, keep it in stock, and promote similar items so revenue is less fragile.`,
          ar: `"${input.mappedTop[0].name}" يحقق أغلب الدخل. اعمل باقات معه، حافظ على توفره، وروّج لمنتجات مشابهة حتى لا يعتمد الدخل على صنف واحد.`,
        },
      });
    }
    if (input.customOrders >= 8) {
      tips.push({
        severity: 'info',
        title: {
          en: 'Custom orders can grow ticket size',
          ar: 'الطلبات الخاصة تقدر تزود قيمة الطلب',
        },
        body: {
          en: 'Reply to custom requests within hours, send photos of similar finished work, and offer a small deposit to convert more quotes.',
          ar: 'رد على الطلبات الخاصة خلال ساعات، ابعت صور شغل مشابه، وقدّم عربون صغير عشان تحول عروض الأسعار لطلبات مؤكدة.',
        },
      });
    }
    const visitsTotal = input.visits.visitsMobile + input.visits.visitsWebsite;
    if (visitsTotal >= 20 && input.conversion < 2) {
      tips.push({
        severity: 'warn',
        title: {
          en: 'Many visitors, few purchases',
          ar: 'زيارات كثيرة ومشتريات قليلة',
        },
        body: {
          en: 'Improve product photos, show delivery time on cards, and add a homepage offer. Follow abandoned carts with a reminder notification.',
          ar: 'حسّن صور المنتجات، وضّح مدة التوصيل على الكروت، وحط عرض على الصفحة الرئيسية. ابعت تذكير لمن ترك السلة.',
        },
      });
    }
    const mobile = input.channelAgg.find((r) => r._id === 'mobile');
    const website = input.channelAgg.find((r) => r._id === 'website');
    if ((mobile?.count ?? 0) > (website?.count ?? 0) * 2 && (website?.count ?? 0) >= 0) {
      tips.push({
        severity: 'ok',
        title: {
          en: 'Push the weaker channel',
          ar: 'قوّي القناة الأضعف',
        },
        body: {
          en: mobile && (mobile.count ?? 0) >= (website?.count ?? 0)
            ? 'Most buyers come from the app. Share website links in ads and WhatsApp so desktop shoppers can checkout too.'
            : 'Most buyers come from the website. Promote the app with a home-screen offer and make checkout shorter on mobile.',
          ar: mobile && (mobile.count ?? 0) >= (website?.count ?? 0)
            ? 'أغلب المشترين من التطبيق. انشر روابط الموقع في الإعلانات وواتساب عشان عملاء الكمبيوتر يشتروا كمان.'
            : 'أغلب المشترين من الموقع. روّج للتطبيق بعرض على الشاشة الرئيسية واختصر خطوات الدفع على الموبايل.',
        },
      });
    }
    if (tips.length === 0) {
      tips.push({
        severity: 'ok',
        title: {
          en: 'Keep the current rhythm',
          ar: 'حافظ على الإيقاع الحالي',
        },
        body: {
          en: 'Highlight best sellers, restock fast, and reply to custom orders quickly. Small weekly ads usually beat one big campaign.',
          ar: 'برز الأكثر مبيعًا، جدد المخزون بسرعة، وارد على الطلبات الخاصة فورًا. إعلان أسبوعي بسيط غالبًا أفضل من حملة كبيرة واحدة.',
        },
      });
    }
    return tips;
  }

  async customers(page: number, limit: number, search?: string, status?: string) {
    const filter: Record<string, unknown> = {
      role: 'customer',
      status: { $ne: 'deleted' },
    };
    if (status) {
      filter.status = status;
    }
    if (search) {
      const rx = new RegExp(search, 'i');
      filter.$or = [{ name: rx }, { email: rx }, { phone: rx }];
    }
    const [items, total] = await Promise.all([
      this.userModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit),
      this.userModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async patchCustomer(id: string, status: string) {
    return this.userModel.findByIdAndUpdate(id, { status }, { new: true });
  }

  async findCustomer(id: string) {
    return this.userModel.findOne({ _id: id, role: 'customer', status: { $ne: 'deleted' } });
  }

  async createStaff(dto: {
    name: string;
    email: string;
    password: string;
    phone?: string;
    role: string;
  }) {
    if (!STAFF_ROLES.includes(dto.role as (typeof STAFF_ROLES)[number])) {
      throw new BadRequestException('Invalid staff role');
    }
    if (dto.role === 'super_admin') {
      throw new BadRequestException('Cannot create another super admin');
    }
    const email = dto.email.toLowerCase();
    const exists = await this.userModel.findOne({ email });
    if (exists) {
      throw new ConflictException('Email already registered');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = await this.userModel.create({
      name: dto.name,
      email,
      passwordHash,
      phone: dto.phone,
      role: dto.role,
      status: 'active',
    });
    return user;
  }

  async listStaff(page: number, limit: number, search?: string, role?: string) {
    const filter: Record<string, unknown> = {
      role: { $in: STAFF_ROLES },
      status: { $ne: 'deleted' },
    };
    if (role) {
      filter.role = role;
    }
    if (search) {
      const rx = new RegExp(search, 'i');
      filter.$or = [{ name: rx }, { email: rx }, { phone: rx }];
    }
    const [items, total] = await Promise.all([
      this.userModel
        .find(filter)
        .select('-passwordHash')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit),
      this.userModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async patchStaff(
    id: string,
    dto: { status?: string; role?: string; name?: string; phone?: string },
  ) {
    const user = await this.userModel.findById(id);
    if (!user || !STAFF_ROLES.includes(user.role as (typeof STAFF_ROLES)[number])) {
      throw new BadRequestException('Staff user not found');
    }
    if (dto.role) {
      if (!STAFF_ROLES.includes(dto.role as (typeof STAFF_ROLES)[number])) {
        throw new BadRequestException('Invalid staff role');
      }
      if (dto.role === 'super_admin') {
        throw new BadRequestException('Cannot create another super admin');
      }
      if (user.role === 'super_admin') {
        throw new BadRequestException('Cannot change super admin role');
      }
      user.role = dto.role;
    }
    if (dto.status) {
      if (user.role === 'super_admin' && dto.status !== 'active') {
        throw new BadRequestException('Cannot block super admin');
      }
      user.status = dto.status;
    }
    if (dto.name) user.name = dto.name;
    if (dto.phone !== undefined) user.phone = dto.phone;
    await user.save();
    return user;
  }

  async roles() {
    return this.roleModel.find().sort({ name: 1 });
  }

  async updateRole(id: string, permissions: string[]) {
    return this.roleModel.findByIdAndUpdate(
      id,
      { permissions },
      { new: true },
    );
  }

  async auditLogs(page: number, limit: number, search?: string) {
    const filter: Record<string, unknown> = {};
    if (search) {
      const rx = new RegExp(search, 'i');
      filter.$or = [{ action: rx }, { entity: rx }, { ip: rx }];
    }
    const [items, total] = await Promise.all([
      this.auditModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('actorId', 'name email role'),
      this.auditModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }
}
