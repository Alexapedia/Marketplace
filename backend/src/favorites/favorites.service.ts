import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { toObjectId } from '../common/utils/mongo';
import { Favorite, FavoriteDocument } from '../schemas/favorite.schema';

@Injectable()
export class FavoritesService {
  constructor(
    @InjectModel(Favorite.name)
    private readonly favoriteModel: Model<FavoriteDocument>,
  ) {}

  async list(userId: string) {
    return this.favoriteModel
      .find({ userId: new Types.ObjectId(userId) })
      .populate('productId')
      .sort({ createdAt: -1 });
  }

  async add(userId: string, productId: string) {
    try {
      return await this.favoriteModel.create({
        userId: new Types.ObjectId(userId),
        productId: toObjectId(productId, 'productId'),
      });
    } catch (err: unknown) {
      if ((err as { code?: number }).code === 11000) {
        throw new ConflictException('Already favorited');
      }
      throw err;
    }
  }

  async remove(userId: string, productId: string) {
    const doc = await this.favoriteModel.findOneAndDelete({
      userId: new Types.ObjectId(userId),
      productId: toObjectId(productId, 'productId'),
    });
    if (!doc) {
      throw new NotFoundException('Favorite not found');
    }
    return { deleted: true };
  }
}
