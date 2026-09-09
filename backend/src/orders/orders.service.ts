import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
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
import {
  AdminUpdateOrderDto,
  ChangeOrderStatusDto,
  CreateOrderDto,
  OrderAddressDto,
} from './dto/order.dto';

@Injectable()
export class OrdersService {
  constructor(
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    private readonly cart: CartService,
    private readonly products: ProductsService,
    private readonly appConfig: AppConfigService,
    private readonly audit: AuditService,
    private readonly notifications: NotificationsService,
  ) {}

  async createFromCart(
    userId: string,
    dto: CreateOrderDto,
    idempotencyKey?: string,
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
          address: dto.address,
          subtotal,
          discount,
          deliveryFee,
          total,
          paymentMethod: 'COD',
          paymentStatus: 'pending',
          orderStatus: 'pending',
          notes: dto.notes,
          idempotencyKey,
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

    await this.cart.clear(userId);
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

    return this.orderModel.create({
      userId: new Types.ObjectId(params.userId),
      orderNumber: generateOrderNumber(),
      items: [
        {
          nameSnapshot: params.productName,
          image: params.image,
          unitPrice: params.unitPrice,
          quantity: params.quantity,
        },
      ],
      address,
      subtotal,
      discount,
      deliveryFee,
      total,
      paymentMethod: 'COD',
      paymentStatus: 'pending',
      orderStatus: 'pending',
      customOrderId: toObjectId(params.customOrderId, 'customOrderId'),
      statusHistory: [
        {
          status: 'pending',
          at: new Date(),
          actorId: new Types.ObjectId(params.userId),
          note: 'Created from custom order proposal',
        },
      ],
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
  }) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 20;
    const filter: Record<string, unknown> = {};
    if (query.status) {
      filter.orderStatus = query.status;
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
      title: {
        en: 'Order update',
        ar: 'تحديث الطلب',
      },
      body: {
        en: `Order ${order.orderNumber} is now ${dto.status}`,
        ar: `الطلب ${order.orderNumber} أصبح ${dto.status}`,
      },
      type: 'order_status',
      data: { orderId: String(order._id), status: dto.status },
    });

    return order;
  }
}
