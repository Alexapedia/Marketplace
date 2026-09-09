import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
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
  ) {}

  async dashboard() {
    const since = new Date();
    since.setDate(since.getDate() - 30);

    const [
      orders,
      pendingCustom,
      unreadChats,
      products,
      newCustomers,
      revenueAgg,
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
      this.userModel.countDocuments({
        role: 'customer',
        createdAt: { $gte: since },
      }),
      this.orderModel.aggregate<{ total: number }>([
        { $match: { orderStatus: { $in: ['completed', 'delivered'] } } },
        { $group: { _id: null, total: { $sum: '$total' } } },
      ]),
    ]);

    return {
      orders,
      pendingCustom,
      unreadChats,
      products,
      newCustomers,
      revenue: revenueAgg[0]?.total ?? 0,
    };
  }

  async reports(from?: string, to?: string) {
    const range: Record<string, unknown> = {};
    if (from || to) {
      range.createdAt = {};
      if (from) {
        (range.createdAt as Record<string, Date>).$gte = new Date(from);
      }
      if (to) {
        (range.createdAt as Record<string, Date>).$lte = new Date(to);
      }
    }

    const [ordersByStatus, topProducts, customStats, rejectedReasons] =
      await Promise.all([
        this.orderModel.aggregate([
          { $match: range },
          { $group: { _id: '$orderStatus', count: { $sum: 1 } } },
        ]),
        this.orderModel.aggregate([
          { $match: range },
          { $unwind: '$items' },
          {
            $group: {
              _id: '$items.nameSnapshot',
              quantity: { $sum: '$items.quantity' },
              revenue: {
                $sum: { $multiply: ['$items.unitPrice', '$items.quantity'] },
              },
            },
          },
          { $sort: { quantity: -1 } },
          { $limit: 10 },
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
      ]);

    return { ordersByStatus, topProducts, customStats, rejectedReasons };
  }

  async customers(page: number, limit: number, search?: string) {
    const filter: Record<string, unknown> = { role: 'customer' };
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

  async auditLogs(page: number, limit: number) {
    const [items, total] = await Promise.all([
      this.auditModel
        .find()
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('actorId', 'name email role'),
      this.auditModel.countDocuments(),
    ]);
    return { data: items, meta: paginationMeta(total, page, limit) };
  }
}
