import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { toObjectId } from '../common/utils/mongo';
import { CustomField, CustomFieldDocument } from '../schemas/custom-field.schema';
import { CreateCustomFieldDto, UpdateCustomFieldDto } from './dto/catalog.dto';

@Injectable()
export class CustomFieldsService {
  constructor(
    @InjectModel(CustomField.name)
    private readonly fieldModel: Model<CustomFieldDocument>,
  ) {}

  async listPublic(categoryId?: string) {
    const filter: Record<string, unknown> = { status: 'published' };
    if (categoryId) {
      filter.categoryId = toObjectId(categoryId, 'categoryId');
    }
    return this.fieldModel.find(filter).sort({ sortOrder: 1 });
  }

  async listAdmin(categoryId?: string) {
    const filter: Record<string, unknown> = {};
    if (categoryId) {
      filter.categoryId = toObjectId(categoryId, 'categoryId');
    }
    return this.fieldModel.find(filter).sort({ sortOrder: 1 });
  }

  async findAdmin(id: string) {
    const doc = await this.fieldModel.findById(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Custom field not found');
    }
    return doc;
  }

  async create(dto: CreateCustomFieldDto) {
    return this.fieldModel.create({
      ...dto,
      categoryId: toObjectId(dto.categoryId, 'categoryId'),
    });
  }

  async update(id: string, dto: UpdateCustomFieldDto) {
    const payload: Record<string, unknown> = { ...dto };
    if (dto.categoryId) {
      payload.categoryId = toObjectId(dto.categoryId, 'categoryId');
    }
    const doc = await this.fieldModel.findByIdAndUpdate(
      toObjectId(id),
      payload,
      { new: true },
    );
    if (!doc) {
      throw new NotFoundException('Custom field not found');
    }
    return doc;
  }

  async remove(id: string) {
    const doc = await this.fieldModel.findByIdAndDelete(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Custom field not found');
    }
    return { deleted: true };
  }
}
