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
    let cart = await this.cartModel.findOne({
      userId: new Types.ObjectId(userId),
    });
    if (!cart) {
      cart = await this.cartModel.create({
        userId: new Types.ObjectId(userId),
        items: [],
      });
    }
    return cart;
  }

  async get(userId: string) {
    return this.getOrCreate(userId);
  }

  async addItem(userId: string, dto: AddCartItemDto) {
    const product = await this.productModel.findById(
      toObjectId(dto.productId, 'productId'),
    );
    if (!product || product.status !== 'published') {
      throw new BadRequestException('Product is unavailable');
    }
    const stock = this.products.stockFor(product, dto.variant);
    if (stock < dto.quantity) {
      throw new BadRequestException('Insufficient stock');
    }
    const unitPrice = this.products.effectivePrice(product, dto.variant);
    const cart = await this.getOrCreate(userId);
    const existing = cart.items.find(
      (item) =>
        String(item.productId) === dto.productId &&
        (item.variant || '') === (dto.variant || '') &&
        (item.size || '') === (dto.size || ''),
    );
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
