import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { toObjectId } from '../common/utils/mongo';
import { OrderAddressDto } from '../orders/dto/order.dto';
import { Address, AddressDocument } from '../schemas/address.schema';
import { UpsertAddressDto } from './dto/address.dto';

const CAIRO = { lat: 30.0444, lng: 31.2357 };

@Injectable()
export class AddressesService {
  constructor(
    @InjectModel(Address.name)
    private readonly addressModel: Model<AddressDocument>,
  ) {}

  async list(userId: string) {
    return this.addressModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ isDefault: -1, createdAt: -1 })
      .lean();
  }

  async findMine(userId: string, id: string) {
    const doc = await this.addressModel
      .findOne({
        _id: toObjectId(id, 'addressId'),
        userId: new Types.ObjectId(userId),
      })
      .lean();
    if (!doc) {
      throw new NotFoundException('Address not found');
    }
    return doc;
  }

  async getDefault(userId: string) {
    const uid = new Types.ObjectId(userId);
    const preferred = await this.addressModel
      .findOne({ userId: uid, isDefault: true })
      .lean();
    if (preferred) return preferred;
    return this.addressModel.findOne({ userId: uid }).sort({ createdAt: -1 }).lean();
  }

  async create(userId: string, dto: UpsertAddressDto) {
    const count = await this.addressModel.countDocuments({
      userId: new Types.ObjectId(userId),
    });
    const makeDefault = dto.isDefault === true || count === 0;
    if (makeDefault) {
      await this.clearDefault(userId);
    }
    return this.addressModel.create({
      userId: new Types.ObjectId(userId),
      label: dto.label?.trim() || 'Home',
      fullName: dto.fullName.trim(),
      phone: dto.phone.trim(),
      city: dto.city.trim(),
      street: dto.street.trim(),
      notes: dto.notes?.trim(),
      lat: dto.lat ?? CAIRO.lat,
      lng: dto.lng ?? CAIRO.lng,
      isDefault: makeDefault,
    });
  }

  async update(userId: string, id: string, dto: UpsertAddressDto) {
    await this.findMine(userId, id);
    if (dto.isDefault === true) {
      await this.clearDefault(userId);
    }
    const doc = await this.addressModel.findOneAndUpdate(
      {
        _id: toObjectId(id, 'addressId'),
        userId: new Types.ObjectId(userId),
      },
      {
        $set: {
          label: dto.label?.trim() || 'Home',
          fullName: dto.fullName.trim(),
          phone: dto.phone.trim(),
          city: dto.city.trim(),
          street: dto.street.trim(),
          notes: dto.notes?.trim(),
          lat: dto.lat ?? CAIRO.lat,
          lng: dto.lng ?? CAIRO.lng,
          ...(dto.isDefault === true ? { isDefault: true } : {}),
        },
      },
      { new: true },
    );
    if (!doc) {
      throw new NotFoundException('Address not found');
    }
    return doc;
  }

  async setDefault(userId: string, id: string) {
    await this.findMine(userId, id);
    await this.clearDefault(userId);
    const doc = await this.addressModel.findOneAndUpdate(
      {
        _id: toObjectId(id, 'addressId'),
        userId: new Types.ObjectId(userId),
      },
      { $set: { isDefault: true } },
      { new: true },
    );
    if (!doc) {
      throw new NotFoundException('Address not found');
    }
    return doc;
  }

  async remove(userId: string, id: string) {
    const doc = await this.addressModel.findOneAndDelete({
      _id: toObjectId(id, 'addressId'),
      userId: new Types.ObjectId(userId),
    });
    if (!doc) {
      throw new NotFoundException('Address not found');
    }
    if (doc.isDefault) {
      const next = await this.addressModel
        .findOne({ userId: new Types.ObjectId(userId) })
        .sort({ createdAt: -1 });
      if (next) {
        next.isDefault = true;
        await next.save();
      }
    }
    return { deleted: true };
  }

  async resolve(
    userId: string,
    addressId?: string,
    fallback?: OrderAddressDto,
  ): Promise<OrderAddressDto> {
    if (addressId) {
      return this.toOrderAddress(await this.findMine(userId, addressId));
    }
    if (fallback?.fullName && fallback.street && fallback.city && fallback.phone) {
      return {
        fullName: fallback.fullName,
        phone: fallback.phone,
        city: fallback.city,
        street: fallback.street,
        notes: fallback.notes,
        lat: fallback.lat,
        lng: fallback.lng,
      };
    }
    const def = await this.getDefault(userId);
    if (def) {
      return this.toOrderAddress(def);
    }
    throw new BadRequestException('Add a delivery address first');
  }

  toOrderAddress(doc: {
    fullName: string;
    phone: string;
    city: string;
    street: string;
    notes?: string;
    lat?: number;
    lng?: number;
  }): OrderAddressDto {
    const lat = Number(doc.lat);
    const lng = Number(doc.lng);
    return {
      fullName: (doc.fullName || '').trim() || 'Customer',
      phone: (doc.phone || '').trim() || '-',
      city: (doc.city || '').trim() || '-',
      street: (doc.street || '').trim() || '-',
      notes: doc.notes,
      lat: Number.isFinite(lat) ? lat : undefined,
      lng: Number.isFinite(lng) ? lng : undefined,
    };
  }

  private clearDefault(userId: string) {
    return this.addressModel.updateMany(
      { userId: new Types.ObjectId(userId), isDefault: true },
      { $set: { isDefault: false } },
    );
  }
}
