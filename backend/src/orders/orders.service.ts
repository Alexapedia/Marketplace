import {
  BadRequestException,
  Injectable,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AddressesService } from '../addresses/addresses.service';
import { AppConfigService } from '../app-config/app-config.service';
import { AuditService } from '../audit/audit.service';
import { CartService } from '../cart/cart.service';
import { ProductsService } from '../catalog/products.service';
import { ORDER_STATUSES } from '../common/constants';
import { paginationMeta } from '../common/dto/pagination.dto';
import { generateOrderNumber, toObjectId } from '../common/utils/mongo';
import { NotificationsService } from '../notifications/notifications.service';
import { Order, OrderDocument, OrderItem } from '../schemas/order.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { TenantContext } from '../tenant/tenant.context';
import {
  AdminUpdateOrderDto,
  ChangeOrderStatusDto,
  CreateOrderDto,
  OrderAddressDto,
} from './dto/order.dto';

@Injectable()
export class OrdersService implements OnModuleInit {
  constructor(
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    private readonly cart: CartService,
    private readonly products: ProductsService,
    private readonly addresses: AddressesService,
    private readonly appConfig: AppConfigService,
    private readonly audit: AuditService,
    private readonly notifications: NotificationsService,
  ) {}

  async onModuleInit() {
    await TenantContext.run({ kind: 'platform' }, async () => {
      await this.orderModel.updateMany(
        { $or: [{ idempotencyKey: null }, { idempotencyKey: '' }] },
        { $unset: { idempotencyKey: 1 } },
      );
      try {
        await this.orderModel.collection.dropIndex('userId_1_idempotencyKey_1');
      } catch {
        // Replaced by a partial unique index below.
      }
      await this.orderModel.syncIndexes();
    });
  }

  async createFromCart(
    userId: string,
    dto: CreateOrderDto,
    idempotencyKey?: string,
    clientHeader?: string,
  ) {
    if (idempotencyKey) {
      const existing = await this.orderModel.findOne({
        userId: new Types.ObjectId(userId),
        idempotencyKey,
      });
      if (existing) {
        return existing;
      }
    }

    const cart = await this.cart.get(userId);
    if (!cart.items.length) {
      throw new BadRequestException('Cart is empty');
    }

    const items: OrderItem[] = [];
    for (const cartItem of cart.items) {
      const product = await this.productModel.findById(cartItem.productId);
      if (!product || product.status !== 'published') {
        throw new BadRequestException(
          `Product ${cartItem.nameSnapshot} is unavailable`,
        );
      }
      const stock = this.products.stockFor(product, cartItem.variant);
      if (stock < cartItem.quantity) {
        throw new BadRequestException(
          `Product ${cartItem.nameSnapshot} is out of stock`,
        );
      }
      const unitPrice = this.products.effectivePrice(product, cartItem.variant);
      items.push({
        productId: product._id,
        nameSnapshot: product.names.en,
        image: product.images?.[0] || cartItem.image,
        unitPrice,
        quantity: cartItem.quantity,
        variant: cartItem.variant,
        size: cartItem.size,
      });
    }

    const address = await this.addresses.resolve(
      userId,
      dto.addressId,
      dto.address,
    );

    const subtotal = items.reduce((sum, i) => sum + i.unitPrice * i.quantity, 0);
    const discount = 0;
    const deliveryFee = await this.appConfig.deliveryFee();
    const total = subtotal - discount + deliveryFee;

    let order: OrderDocument | null = null;
    for (let attempt = 0; attempt < 6; attempt++) {
      try {
        order = await this.orderModel.create({
          userId: new Types.ObjectId(userId),
          orderNumber: generateOrderNumber(),
          items,
          address,
          subtotal,
          discount,
          deliveryFee,
          total,
          paymentMethod: 'COD',
          paymentStatus: 'pending',
          orderStatus: 'pending',
          channel: this.resolveChannel(dto.channel ?? clientHeader),
          notes: dto.notes,
          ...(idempotencyKey ? { idempotencyKey } : {}),
          statusHistory: [
            {
              status: 'pending',
              at: new Date(),
              actorId: new Types.ObjectId(userId),
              note: 'Order created',
            },
          ],
        });
        break;
      } catch (err: unknown) {
        if ((err as { code?: number }).code === 11000 && idempotencyKey) {
          const dup = await this.orderModel.findOne({
            userId: new Types.ObjectId(userId),
            idempotencyKey,
          });
          if (dup) {
            return dup;
          }
        }
        if (attempt === 5) {
          throw err;
        }
      }
    }

    await this.products.applyStockDelta(items, -1);
    await this.cart.clear(userId);
    if (order) {
      await this.notifyNewOrder(order);
    }
    return order;
  }

  async createFromProposal(params: {
    userId: string;
    customOrderId: string;
    productName: string;
    image?: string;
    unitPrice: number;
    quantity: number;
    address?: OrderAddressDto;
    userName?: string;
    userPhone?: string;
    channel?: string;
  }) {
    const subtotal = params.unitPrice * params.quantity;
    const discount = 0;
    const deliveryFee = await this.appConfig.deliveryFee();
    const total = subtotal - discount + deliveryFee;
    const address = params.address ?? {
      fullName: params.userName || 'Customer',
      phone: params.userPhone || '-',
      city: '-',
      street: '-',
      notes: `Custom order ${params.customOrderId}`,
    };

    const name =
      (typeof params.productName === 'string' ? params.productName : '')
        .trim() || `Custom order ${params.customOrderId}`;
    const image =
      typeof params.image === 'string' && params.image.trim()
        ? params.image.trim()
        : undefined;
    const lat = Number(address.lat);
    const lng = Number(address.lng);
    try {
      const created = await this.orderModel.create({
      userId: new Types.ObjectId(params.userId),
      orderNumber: generateOrderNumber(),
      items: [
        {
          nameSnapshot: name,
          image,
          unitPrice: Number(params.unitPrice) || 0,
          quantity: Math.max(1, Number(params.quantity) || 1),
        },
      ],
      address: {
        fullName: (address.fullName || '').trim() || 'Customer',
        phone: (address.phone || '').trim() || '-',
        city: (address.city || '').trim() || '-',
        street: (address.street || '').trim() || '-',
        notes: address.notes,
        lat: Number.isFinite(lat) ? lat : undefined,
        lng: Number.isFinite(lng) ? lng : undefined,
      },
      subtotal,
      discount,
      deliveryFee,
      total,
      paymentMethod: 'COD',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      channel: this.resolveChannel(params.channel),
      customOrderId: toObjectId(params.customOrderId, 'customOrderId'),
      idempotencyKey: `custom-order:${params.customOrderId}`,
      statusHistory: [
        {
          status: 'pending',
          at: new Date(),
          actorId: new Types.ObjectId(params.userId),
          note: 'Created from custom order proposal',
        },
      ],
    });
      await this.notifyNewOrder(created);
      return created;
    } catch (err) {
      const message =
        err instanceof Error
          ? err.message
          : 'Could not create order from proposal';
      throw new BadRequestException(message);
    }
  }

  async findByCustomOrderId(customOrderId: string) {
    return this.orderModel.findOne({
      customOrderId: toObjectId(customOrderId, 'customOrderId'),
    });
  }

  async listMine(userId: string, page: number, limit: number) {
    const filter = { userId: new Types.ObjectId(userId) };
    const [items, total] = await Promise.all([
      this.orderModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit),
      this.orderModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async findMine(userId: string, id: string) {
    const doc = await this.orderModel.findOne({
      _id: toObjectId(id),
      userId: new Types.ObjectId(userId),
    });
    if (!doc) {
      throw new NotFoundException('Order not found');
    }
    return doc;
  }

  async cancel(userId: string, id: string) {
    const order = await this.findMine(userId, id);
    if (!['pending', 'accepted'].includes(order.orderStatus)) {
      throw new BadRequestException('Order cannot be cancelled');
    }
    const old = order.orderStatus;
    order.orderStatus = 'cancelled';
    order.paymentStatus = 'cancelled';
    order.statusHistory.push({
      status: 'cancelled',
      at: new Date(),
      actorId: new Types.ObjectId(userId),
      note: 'Cancelled by customer',
    });
    await order.save();
    await this.restoreStockIfNeeded(order, old, 'cancelled');
    await this.audit.log({
      actorId: userId,
      action: 'order.cancel',
      entity: 'Order',
      entityId: String(order._id),
      oldValue: { orderStatus: old },
      newValue: { orderStatus: 'cancelled' },
    });
    return order;
  }

  async listAdmin(query: {
    status?: string;
    page?: number;
    limit?: number;
    search?: string;
    channel?: string;
  }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const filter: Record<string, unknown> = {};
    if (query.status) {
      filter.orderStatus = query.status;
    }
    if (query.channel) {
      filter.channel = query.channel;
    }
    if (query.search) {
      filter.$or = [
        { orderNumber: new RegExp(query.search, 'i') },
        { 'address.fullName': new RegExp(query.search, 'i') },
      ];
    }
    const [items, total] = await Promise.all([
      this.orderModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('userId', 'name email phone'),
      this.orderModel.countDocuments(filter),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async findAdmin(id: string) {
    const doc = await this.orderModel
      .findById(toObjectId(id))
      .populate('userId', 'name email phone');
    if (!doc) {
      throw new NotFoundException('Order not found');
    }
    return doc;
  }

  async updateAdmin(id: string, dto: AdminUpdateOrderDto) {
    const doc = await this.orderModel.findByIdAndUpdate(toObjectId(id), dto, {
      new: true,
    });
    if (!doc) {
      throw new NotFoundException('Order not found');
    }
    return doc;
  }

  async changeStatus(
    id: string,
    dto: ChangeOrderStatusDto,
    actorId: string,
    ip?: string,
  ) {
    if (!ORDER_STATUSES.includes(dto.status as (typeof ORDER_STATUSES)[number])) {
      throw new BadRequestException('Invalid status');
    }
    if (dto.status === 'rejected' && !dto.rejectionReason) {
      throw new BadRequestException('rejectionReason is required');
    }
    const order = await this.findAdmin(id);
    const old = order.orderStatus;
    order.orderStatus = dto.status;
    if (dto.status === 'rejected') {
      order.rejectionReason = dto.rejectionReason;
    }
    if (dto.status === 'cancelled') {
      order.paymentStatus = 'cancelled';
    }
    if (dto.status === 'completed' || dto.status === 'delivered') {
      if (order.paymentMethod === 'COD') {
        order.paymentStatus = 'paid';
      }
    }
    order.statusHistory.push({
      status: dto.status,
      at: new Date(),
      actorId: new Types.ObjectId(actorId),
      note: dto.rejectionReason,
    });
    await order.save();
    await this.restoreStockIfNeeded(order, old, dto.status);

    await this.audit.log({
      actorId,
      action: 'order.status',
      entity: 'Order',
      entityId: String(order._id),
      oldValue: { orderStatus: old },
      newValue: { orderStatus: dto.status, rejectionReason: dto.rejectionReason },
      ip,
    });

    await this.notifications.createAndOptionallyPush({
      userId: String(order.userId._id ?? order.userId),
      ...this.statusNotification(dto.status, order.orderNumber, dto.rejectionReason),
      type: 'order_status',
      data: {
        orderId: String(order._id),
        status: dto.status,
        orderNumber: order.orderNumber,
        ...(dto.rejectionReason ? { rejectionReason: dto.rejectionReason } : {}),
      },
    });

    return order;
  }

  private restoreStockIfNeeded(
    order: {
      items: { productId?: unknown; variant?: string; quantity: number }[];
    },
    previousStatus: string,
    nextStatus: string,
  ) {
    const released = ['cancelled', 'rejected'];
    const sold = ['delivered', 'completed'];
    if (
      !released.includes(nextStatus) ||
      released.includes(previousStatus) ||
      sold.includes(previousStatus)
    ) {
      return;
    }
    return this.products.applyStockDelta(
      order.items.map((item) => ({
        productId: item.productId as { toString(): string } | undefined,
        variant: item.variant,
        quantity: item.quantity,
      })),
      1,
    );
  }

  private statusNotification(
    status: string,
    orderNumber: string,
    reason?: string,
  ) {
    const n = orderNumber;
    const copies: Record<string, { title: { en: string; ar: string }; body: { en: string; ar: string } }> = {
      accepted: {
        title: { en: 'Order confirmed', ar: 'تم تأكيد الطلب' },
        body: { en: `Order ${n} was confirmed.`, ar: `تم تأكيد الطلب ${n}.` },
      },
      preparing: {
        title: { en: 'Preparing your order', ar: 'جاري تجهيز طلبك' },
        body: { en: `We started preparing order ${n}.`, ar: `بدأنا تجهيز الطلب ${n}.` },
      },
      ready: {
        title: { en: 'Order is ready', ar: 'طلبك جاهز' },
        body: { en: `Order ${n} is ready.`, ar: `الطلب ${n} جاهز.` },
      },
      out_for_delivery: {
        title: { en: 'Order on the way', ar: 'الطلب في الطريق' },
        body: { en: `Order ${n} is out for delivery.`, ar: `الطلب ${n} خرج للتوصيل.` },
      },
      delivered: {
        title: { en: 'Order delivered', ar: 'تم توصيل الطلب' },
        body: { en: `Order ${n} was delivered.`, ar: `تم توصيل الطلب ${n}.` },
      },
      completed: {
        title: { en: 'Order completed', ar: 'اكتمل الطلب' },
        body: { en: `Order ${n} is complete.`, ar: `اكتمل الطلب ${n}.` },
      },
      cancelled: {
        title: { en: 'Order cancelled', ar: 'تم إلغاء الطلب' },
        body: { en: `Order ${n} was cancelled.`, ar: `تم إلغاء الطلب ${n}.` },
      },
      rejected: {
        title: { en: 'Order rejected', ar: 'تم رفض الطلب' },
        body: {
          en: reason ? `Order ${n} was rejected: ${reason}` : `Order ${n} was rejected.`,
          ar: reason ? `تم رفض الطلب ${n}: ${reason}` : `تم رفض الطلب ${n}.`,
        },
      },
    };
    return (
      copies[status] ?? {
        title: { en: 'Order update', ar: 'تحديث الطلب' },
        body: { en: `Order ${n} is now ${status}.`, ar: `الطلب ${n} أصبح ${status}.` },
      }
    );
  }

  private resolveChannel(raw?: string): 'mobile' | 'website' {
    return raw === 'website' ? 'website' : 'mobile';
  }

  private async notifyNewOrder(order: OrderDocument) {
    try {
      await this.notifications.notifyRoles({
        roles: ['super_admin', 'admin', 'order_manager'],
        title: { en: 'New order', ar: 'طلب جديد' },
        body: {
          en: `Order ${order.orderNumber} needs attention.`,
          ar: `الطلب ${order.orderNumber} يحتاج متابعة.`,
        },
        type: 'new_order',
        data: {
          orderId: String(order._id),
          orderNumber: order.orderNumber,
        },
      });
    } catch {
      // Inbox alerts should not fail checkout.
    }
  }
}
