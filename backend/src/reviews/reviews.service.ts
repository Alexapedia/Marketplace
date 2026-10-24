import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { paginationMeta } from '../common/dto/pagination.dto';
import type { AuthUser } from '../common/types/auth-user';
import { toObjectId } from '../common/utils/mongo';
import { Order, OrderDocument } from '../schemas/order.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { Review, ReviewDocument, ReviewTarget } from '../schemas/review.schema';
import { CreateReviewDto } from './dto/review.dto';

const RATEABLE_ORDER = new Set(['delivered', 'completed']);
export const HIGHLIGHT_MIN = 3.5;

@Injectable()
export class ReviewsService {
  constructor(
    @InjectModel(Review.name)
    private readonly reviewModel: Model<ReviewDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
  ) {}

  async highlights(limit = 12) {
    const items = await this.reviewModel
      .find({
        hidden: { $ne: true },
        rating: { $gte: HIGHLIGHT_MIN },
        comment: { $nin: [null, ''] },
      })
      .sort({ createdAt: -1 })
      .limit(Math.min(limit, 40))
      .populate('userId', 'name');
    return items.map((doc) => this.present(doc));
  }

  async listPublic(query: {
    targetType?: ReviewTarget;
    targetId?: string;
    page?: number;
    limit?: number;
    user?: AuthUser;
  }) {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const filter: Record<string, unknown> = { hidden: { $ne: true } };
    if (query.targetType) {
      filter.targetType = query.targetType;
    }
    if (query.targetId) {
      filter.targetId = toObjectId(query.targetId, 'targetId');
    }
    const [items, total] = await Promise.all([
      this.reviewModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('userId', 'name'),
      this.reviewModel.countDocuments(filter),
    ]);

    let ratingAvg = 0;
    let ratingCount = 0;
    let canRate = false;
    let myReview: ReturnType<ReviewsService['present']> | null = null;

    if (query.targetType === 'product' && query.targetId) {
      const product = await this.productModel
        .findById(toObjectId(query.targetId))
        .select('ratingAvg ratingCount')
        .lean();
      ratingAvg = Number(product?.ratingAvg ?? 0);
      ratingCount = Number(product?.ratingCount ?? 0);
      if (query.user?.type === 'customer') {
        myReview = await this.findMine(
          query.user.userId,
          this.scope('product', query.targetId),
        );
        canRate = !myReview;
      }
    } else if (
      query.user?.type === 'customer' &&
      (query.targetType === 'app' || query.targetType === 'website')
    ) {
      canRate = true;
      myReview = await this.findMine(
        query.user.userId,
        this.scope(query.targetType),
      );
      if (myReview) canRate = false;
    }

    return {
      data: {
        items: items.map((doc) => this.present(doc)),
        ratingAvg,
        ratingCount,
        canRate,
        myReview,
      },
      meta: paginationMeta(total, page, limit),
    };
  }

  async listAdmin(query: {
    targetType?: ReviewTarget;
    targetId?: string;
    hidden?: string;
    page?: number;
    limit?: number;
  }) {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const filter: Record<string, unknown> = {};
    if (query.targetType) filter.targetType = query.targetType;
    if (query.targetId) {
      filter.targetId = toObjectId(query.targetId, 'targetId');
    }
    if (query.hidden === 'true') filter.hidden = true;
    if (query.hidden === 'false') filter.hidden = { $ne: true };
    const [items, total] = await Promise.all([
      this.reviewModel
        .find(filter)
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('userId', 'name email'),
      this.reviewModel.countDocuments(filter),
    ]);
    return {
      data: items.map((doc) => this.present(doc)),
      meta: paginationMeta(total, page, limit),
    };
  }

  async create(user: AuthUser, dto: CreateReviewDto) {
    if (user.type !== 'customer') {
      throw new ForbiddenException('Only customers can leave ratings');
    }
    const rating = Math.round(dto.rating * 2) / 2;
    if (rating < 1 || rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }
    const comment = (dto.comment ?? '').trim();
    const targetType = dto.targetType;
    const targetId = dto.targetId;
    let targetName: { en: string; ar: string } | undefined;

    if (targetType === 'product') {
      if (!targetId) {
        throw new BadRequestException('targetId is required for product ratings');
      }
      const product = await this.productModel.findById(toObjectId(targetId));
      if (!product) {
        throw new NotFoundException('Product not found');
      }
      const allowed = await this.canRateProduct(user.userId, targetId);
      if (!allowed) {
        throw new ForbiddenException('You already rated this product');
      }
      targetName = product.names;
    } else if (targetType === 'order') {
      if (!targetId) {
        throw new BadRequestException('targetId is required for order ratings');
      }
      const order = await this.orderModel.findOne({
        _id: toObjectId(targetId),
        userId: new Types.ObjectId(user.userId),
      });
      if (!order) {
        throw new NotFoundException('Order not found');
      }
      if (!RATEABLE_ORDER.has(order.orderStatus)) {
        throw new ForbiddenException(
          'Rate an order after it is delivered or completed',
        );
      }
      if (order.rating) {
        throw new ConflictException('Order already rated');
      }
      targetName = { en: order.orderNumber, ar: order.orderNumber };
      order.rating = rating;
      order.ratingComment = comment;
      order.ratedAt = new Date();
      await order.save();
      await this.applyOrderRatingToProducts(
        user.userId,
        order,
        rating,
        comment,
      );
    } else if (targetType === 'app' || targetType === 'website') {
      targetName = { en: 'Zezo Store', ar: 'متجر زيزو' };
    } else {
      throw new BadRequestException('Invalid target');
    }

    const scope = this.scope(targetType, targetId);
    const existing = await this.reviewModel.findOne({
      userId: new Types.ObjectId(user.userId),
      scope,
    });
    if (existing) {
      throw new ConflictException('You already rated this');
    }

    const created = await this.reviewModel.create({
      userId: new Types.ObjectId(user.userId),
      targetType,
      targetId: targetId ? toObjectId(targetId) : undefined,
      scope,
      rating,
      comment,
      targetName,
      hidden: false,
    });
    if (targetType === 'product' && targetId) {
      await this.recalcProduct(targetId);
    }
    const populated = await created.populate('userId', 'name');
    return this.present(populated);
  }

  async patch(id: string, hidden?: boolean) {
    const doc = await this.reviewModel.findById(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Review not found');
    }
    if (hidden !== undefined) {
      doc.hidden = hidden;
      await doc.save();
    }
    if (doc.targetType === 'product' && doc.targetId) {
      await this.recalcProduct(String(doc.targetId));
    }
    return this.present(await doc.populate('userId', 'name email'));
  }

  async remove(id: string) {
    const doc = await this.reviewModel.findByIdAndDelete(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Review not found');
    }
    if (doc.targetType === 'product' && doc.targetId) {
      await this.recalcProduct(String(doc.targetId));
    }
    if (doc.targetType === 'order' && doc.targetId) {
      await this.orderModel.updateOne(
        { _id: doc.targetId },
        { $unset: { rating: 1, ratingComment: 1, ratedAt: 1 } },
      );
    }
    return { deleted: true };
  }

  private async canRateProduct(userId: string, productId: string) {
    const already = await this.reviewModel.exists({
      userId: new Types.ObjectId(userId),
      scope: this.scope('product', productId),
    });
    return !already;
  }

  private async applyOrderRatingToProducts(
    userId: string,
    order: OrderDocument,
    rating: number,
    comment: string,
  ) {
    const ids = [
      ...new Set(
        (order.items ?? [])
          .map((item) => this.itemProductId(item.productId))
          .filter(Boolean),
      ),
    ];
    for (const productId of ids) {
      const scope = this.scope('product', productId);
      const exists = await this.reviewModel.exists({
        userId: new Types.ObjectId(userId),
        scope,
      });
      if (exists) continue;
      const product = await this.productModel.findById(productId);
      if (!product) continue;
      await this.reviewModel.create({
        userId: new Types.ObjectId(userId),
        targetType: 'product',
        targetId: product._id,
        scope,
        rating,
        comment,
        targetName: product.names,
        hidden: false,
      });
      await this.recalcProduct(productId);
    }
  }

  private itemProductId(value: unknown): string {
    if (!value) return '';
    if (typeof value === 'string') return value;
    if (typeof value === 'object') {
      const rec = value as { _id?: unknown; id?: unknown };
      if (rec._id) return String(rec._id);
      if (rec.id) return String(rec.id);
    }
    return String(value);
  }

  private async findMine(userId: string, scope: string) {
    const doc = await this.reviewModel
      .findOne({ userId: new Types.ObjectId(userId), scope })
      .populate('userId', 'name');
    return doc ? this.present(doc) : null;
  }

  private async recalcProduct(productId: string) {
    const stats = await this.reviewModel.aggregate<{
      avg: number;
      count: number;
    }>([
      {
        $match: {
          targetType: 'product',
          targetId: toObjectId(productId),
          hidden: { $ne: true },
        },
      },
      { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } },
    ]);
    const avg = stats[0] ? Math.round(stats[0].avg * 10) / 10 : 0;
    const count = stats[0]?.count ?? 0;
    await this.productModel.updateOne(
      { _id: toObjectId(productId) },
      { $set: { ratingAvg: avg, ratingCount: count } },
    );
  }

  private scope(type: ReviewTarget, targetId?: string) {
    if (type === 'app' || type === 'website') return type;
    return `${type}:${targetId}`;
  }

  private present(doc: ReviewDocument | Record<string, unknown>) {
    const json = (
      typeof (doc as ReviewDocument).toJSON === 'function'
        ? (doc as ReviewDocument).toJSON()
        : doc
    ) as Record<string, unknown>;
    const user = json.userId as
      | { _id?: unknown; name?: string; email?: string }
      | string
      | undefined;
    const userObj = user && typeof user === 'object' ? user : null;
    const targetId = json.targetId
      ? String(
          typeof json.targetId === 'object' && json.targetId !== null
            ? (json.targetId as { _id?: unknown })._id ?? json.targetId
            : json.targetId,
        )
      : null;
    return {
      id: String(json._id ?? json.id ?? ''),
      targetType: json.targetType,
      targetId,
      rating: Number(json.rating ?? 0),
      comment: String(json.comment ?? ''),
      targetName: json.targetName ?? null,
      hidden: Boolean(json.hidden),
      createdAt: json.createdAt,
      userName: userObj?.name || 'Customer',
      userEmail: userObj?.email,
    };
  }
}
