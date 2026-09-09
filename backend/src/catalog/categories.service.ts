import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { toObjectId } from '../common/utils/mongo';
import { Category, CategoryDocument } from '../schemas/category.schema';
import { CreateCategoryDto, UpdateCategoryDto } from './dto/catalog.dto';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectModel(Category.name)
    private readonly categoryModel: Model<CategoryDocument>,
  ) {}

  async listPublic() {
    const items = await this.categoryModel
      .find({ status: 'published' })
      .sort({ sortOrder: 1, createdAt: 1 });
    return this.asTree(items);
  }

  async findPublic(id: string) {
    const doc = await this.categoryModel.findOne({
      _id: toObjectId(id),
      status: 'published',
    });
    if (!doc) {
      throw new NotFoundException('Category not found');
    }
    return doc;
  }

  async listAdmin() {
    return this.categoryModel.find().sort({ sortOrder: 1, createdAt: 1 });
  }

  async findAdmin(id: string) {
    const doc = await this.categoryModel.findById(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Category not found');
    }
    return doc;
  }

  async create(dto: CreateCategoryDto) {
    return this.categoryModel.create({
      ...dto,
      parentId: dto.parentId ? toObjectId(dto.parentId) : null,
    });
  }

  async update(id: string, dto: UpdateCategoryDto) {
    const payload: Record<string, unknown> = { ...dto };
    if (dto.parentId !== undefined) {
      payload.parentId = dto.parentId ? toObjectId(dto.parentId) : null;
    }
    const doc = await this.categoryModel.findByIdAndUpdate(
      toObjectId(id),
      payload,
      { new: true },
    );
    if (!doc) {
      throw new NotFoundException('Category not found');
    }
    return doc;
  }

  async remove(id: string) {
    const doc = await this.categoryModel.findByIdAndDelete(toObjectId(id));
    if (!doc) {
      throw new NotFoundException('Category not found');
    }
    return { deleted: true };
  }

  private asTree(items: CategoryDocument[]) {
    const map = new Map<string, Record<string, unknown>>();
    items.forEach((c) => {
      map.set(String(c._id), { ...c.toObject(), children: [] });
    });
    const roots: Record<string, unknown>[] = [];
    map.forEach((node) => {
      const parentId = node.parentId ? String(node.parentId) : null;
      if (parentId && map.has(parentId)) {
        (map.get(parentId)!.children as Record<string, unknown>[]).push(node);
      } else {
        roots.push(node);
      }
    });
    return roots;
  }
}
