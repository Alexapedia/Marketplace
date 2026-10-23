import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ProductsService } from '../catalog/products.service';
import { toObjectId } from '../common/utils/mongo';
import { Cart, CartDocument } from '../schemas/cart.schema';
import { Product, ProductDocument } from '../schemas/product.schema';
import { AddCartItemDto, UpdateCartItemDto } from './dto/cart.dto';

@Injectable()
export class CartService {
  constructor(
    @InjectModel(Cart.name) private readonly cartModel: Model<CartDocument>,
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    private readonly products: ProductsService,
  ) {}

  async getOrCreate(userId: string) {
    const filter = { userId: new Types.ObjectId(userId) };
    // Atomic upsert: concurrent first loads (e.g. app start fetching the cart
    // badge and the cart screen together) all get the same cart instead of
    // racing on the unique tenantId+userId index.
    try {
      return await this.cartModel.findOneAndUpdate(
        filter,
        { $setOnInsert: { items: [] } },
        { upsert: true, new: true },
      );
    } catch (err) {
      if ((err as { code?: number }).code !== 11000) throw err;
      const cart = await this.cartModel.findOne(filter);
      if (!cart) throw err;
      return cart;
    }
  }

  /** Returns the cart priced at current product prices (what checkout charges). */
  async get(userId: string) {
    const cart = await this.getOrCreate(userId);
    if (!cart.items.length) {
      return cart;
    }
    const products = await this.productModel.find({
      _id: { $in: cart.items.map((i) => i.productId) },
    });
    const byId = new Map(products.map((p) => [String(p._id), p]));
    let changed = false;
    for (const item of cart.items) {
      const product = byId.get(String(item.productId));
      if (!product) {
        continue;
      }
      const price = this.products.effectivePrice(product, item.variant);
      if (item.unitPrice !== price) {
        item.unitPrice = price;
        changed = true;
      }
    }
    if (changed) {
      cart.markModified('items');
      await cart.save();
    }
    return cart;
  }

  async addItem(userId: string, dto: AddCartItemDto) {
    const product = await this.productModel.findById(
      toObjectId(dto.productId, 'productId'),
    );
    if (!product || product.status !== 'published') {
      throw new BadRequestException('Product is unavailable');
    }
    if (
      dto.variant &&
      product.variants?.length &&
      !product.variants.some(
        (v) => v.name === dto.variant || v.sku === dto.variant,
      )
    ) {
      throw new BadRequestException('Unknown variant');
    }
    const stock = this.products.stockFor(product, dto.variant);
    const unitPrice = this.products.effectivePrice(product, dto.variant);
    const cart = await this.getOrCreate(userId);
    const existing = cart.items.find(
      (item) =>
        String(item.productId) === dto.productId &&
        (item.variant || '') === (dto.variant || '') &&
        (item.size || '') === (dto.size || ''),
    );
    if (stock < (existing?.quantity ?? 0) + dto.quantity) {
      throw new BadRequestException('Insufficient stock');
    }
    if (existing) {
      existing.quantity += dto.quantity;
      existing.unitPrice = unitPrice;
      existing.nameSnapshot = product.names.en;
      existing.image = product.images?.[0];
    } else {
      cart.items.push({
        productId: product._id,
        nameSnapshot: product.names.en,
        image: product.images?.[0],
        unitPrice,
        quantity: dto.quantity,
        variant: dto.variant,
        size: dto.size,
      } as never);
    }
    cart.markModified('items');
    await cart.save();
    return cart;
  }

  async updateItem(userId: string, itemId: string, dto: UpdateCartItemDto) {
    const cart = await this.getOrCreate(userId);
    const item = cart.items.find((i) => String((i as { _id?: Types.ObjectId })._id) === itemId);
    if (!item) {
      throw new NotFoundException('Cart item not found');
    }
    if (dto.quantity <= 0) {
      cart.items = cart.items.filter(
        (i) => String((i as { _id?: Types.ObjectId })._id) !== itemId,
      ) as typeof cart.items;
    } else {
      const product = await this.productModel.findById(item.productId);
      if (
        !product ||
        dto.quantity > this.products.stockFor(product, item.variant)
      ) {
        throw new BadRequestException('Insufficient stock');
      }
      item.quantity = dto.quantity;
    }
    cart.markModified('items');
    await cart.save();
    return cart;
  }

  async removeItem(userId: string, itemId: string) {
    const cart = await this.getOrCreate(userId);
    const before = cart.items.length;
    cart.items = cart.items.filter(
      (i) => String((i as { _id?: Types.ObjectId })._id) !== itemId,
    ) as typeof cart.items;
    if (cart.items.length === before) {
      throw new NotFoundException('Cart item not found');
    }
    cart.markModified('items');
    await cart.save();
    return cart;
  }

  async clear(userId: string) {
    const cart = await this.getOrCreate(userId);
    cart.items = [];
    await cart.save();
    return cart;
  }
}
