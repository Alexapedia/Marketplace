import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { paginationMeta } from '../common/dto/pagination.dto';
import { toObjectId } from '../common/utils/mongo';
import { Product, ProductDocument } from '../schemas/product.schema';
import { CreateProductDto, UpdateProductDto } from './dto/catalog.dto';

export interface ProductQuery {
  categoryId?: string;
  search?: string;
  featured?: string | boolean;
  newArrival?: string | boolean;
  bestSeller?: string | boolean;
  gender?: string;
  status?: string;
  page?: number;
  limit?: number;
  sort?: string;
}

@Injectable()
export class ProductsService {
  constructor(
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
  ) {}

  async listPublic(query: ProductQuery) {
    return this.list({ ...query, status: 'published' }, true);
  }

  async listAdmin(query: ProductQuery) {
    return this.list(query, false);
  }

  private async list(query: ProductQuery, publicOnly: boolean) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 20;
    const filter: Record<string, unknown> = {};

    if (publicOnly) {
      filter.status = 'published';
    } else if (query.status) {
      filter.status = query.status;
    }

    if (query.categoryId) {
      filter.categoryId = toObjectId(query.categoryId, 'categoryId');
    }
    if (query.gender) {
      filter.gender = query.gender;
    }
    if (this.isTrue(query.featured)) {
      filter['flags.featured'] = true;
    }
    if (this.isTrue(query.newArrival)) {
      filter['flags.newArrival'] = true;
    }
    if (this.isTrue(query.bestSeller)) {
      filter['flags.bestSeller'] = true;
    }
    if (query.search) {
      const rx = new RegExp(query.search, 'i');
      filter.$or = [{ 'names.en': rx }, { 'names.ar': rx }];
    }

    const sort = this.parseSort(query.sort);
    const [items, total] = await Promise.all([
      this.productModel
        .find(filter)
        .sort(sort)
        .skip((page - 1) * limit)
        .limit(limit)
        .populate('categoryId'),
      this.productModel.countDocuments(filter),
    ]);

    return { data: items, meta: paginationMeta(total, page, limit) };
  }

  async findPublic(id: string) {
    const doc = await this.productModel
      .findOne({ _id: toObjectId(id), status: 'published' })
      .populate('categoryId relatedProductIds');
    if (!doc) {
      throw new NotFoundException('Product not found');
    }
    return doc;
  }

  async findAdmin(id: string) {
    const doc = await this.productModel
      .findById(toObjectId(id))
      .populate('categoryId relatedProductIds');
    if (!doc) {
      throw new NotFoundException('Product not found');
    }
    return doc;
  }

  async create(dto: CreateProductDto) {
    return this.productModel.create({
      ...dto,
      categoryId: toObjectId(dto.categoryId, 'categoryId'),
      relatedProductIds: (dto.relatedProductIds ?? []).map((id) =>
        toObjectId(id),
      ),
      flags: {
        featured: dto.flags?.featured ?? false,
        newArrival: dto.flags?.newArrival ?? false,
        bestSeller: dto.flags?.bestSeller ?? false,
      },
    });
  }

  async update(id: string, dto: UpdateProductDto) {
    const payload: Record<string, unknown> = { ...dto };
    if (dto.categoryId) {
      payload.categoryId = toObjectId(dto.categoryId, 'categoryId');
    }
    if (dto.relatedProductIds) {
      payload.relatedProductIds = dto.relatedProductIds.map((rid) =>
        toObjectId(rid),
      );
    }
    const doc = await this.productModel.findByIdAndUpdate(
      toObjectId(id),
      payload,
      { new: true },
    );
    if (!doc) {
      throw new NotFoundException('Product not found');
    }
    return doc;
  }

  async remove(id: string) {
    const doc = await this.productModel.findByIdAndDelete(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Product not found');
    }
    return { deleted: true };
  }

  effectivePrice(product: ProductDocument, variantName?: string): number {
    if (variantName && product.variants?.length) {
      const variant = product.variants.find(
        (v) => v.name === variantName || v.sku === variantName,
      );
      if (variant?.price != null) {
        return variant.price;
      }
    }
    if (product.salePrice != null && product.salePrice > 0) {
      return product.salePrice;
    }
    return product.price;
  }

  stockFor(product: ProductDocument, variantName?: string): number {
    if (variantName && product.variants?.length) {
      const variant = product.variants.find(
        (v) => v.name === variantName || v.sku === variantName,
      );
      if (variant?.stock != null) {
        return variant.stock;
      }
    }
    return product.stock ?? 0;
  }

  async applyStockDelta(
    items: {
      productId?: { toString(): string } | string;
      variant?: string;
      quantity: number;
    }[],
    direction: 1 | -1,
  ) {
    for (const item of items) {
      if (!item.productId) {
        continue;
      }
      const qty = Math.abs(Number(item.quantity) || 0) * direction;
      if (!qty) {
        continue;
      }
      const product = await this.productModel.findById(
        toObjectId(String(item.productId)),
      );
      if (!product) {
        continue;
      }
      if (item.variant && product.variants?.length) {
        const variant = product.variants.find(
          (v) => v.name === item.variant || v.sku === item.variant,
        );
        if (variant) {
          variant.stock = Math.max(0, (variant.stock ?? 0) + qty);
          await product.save();
          continue;
        }
      }
      product.stock = Math.max(0, (product.stock ?? 0) + qty);
      await product.save();
    }
  }

  private isTrue(value: unknown) {
    return value === true || value === 'true' || value === '1';
  }

  private parseSort(sort?: string) {
    if (!sort) {
      return { sortOrder: 1, createdAt: -1 } as const;
    }
    const dir = sort.startsWith('-') ? -1 : 1;
    const field = sort.replace(/^-/, '');
    const allowed = ['price', 'createdAt', 'sortOrder', 'stock', 'salePrice'];
    if (!allowed.includes(field)) {
      return { sortOrder: 1, createdAt: -1 } as const;
    }
    return { [field]: dir } as Record<string, 1 | -1>;
  }
}
