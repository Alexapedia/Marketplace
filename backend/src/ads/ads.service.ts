import { Injectable, Logger, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { paginationMeta } from '../common/dto/pagination.dto';
import { Ad, AdDocument } from '../schemas/ad.schema';
import { AppConfig, AppConfigDocument } from '../schemas/app-config.schema';
import { UpsertAdDto } from './dto/ad.dto';

@Injectable()
export class AdsService implements OnModuleInit {
  private readonly logger = new Logger(AdsService.name);

  constructor(
    @InjectModel(Ad.name) private readonly ads: Model<AdDocument>,
    @InjectModel(AppConfig.name)
    private readonly config: Model<AppConfigDocument>,
  ) {}

  async onModuleInit() {
    try {
      await this.ads.deleteMany({
        $or: [{ image: '' }, { image: null }, { image: { $exists: false } }],
      });
      await this.migrateFromConfig();
    } catch (err) {
      this.logger.warn(`Ads migrate skipped: ${(err as Error).message}`);
    }
  }

  async listPublic(placement?: string) {
    const filter: Record<string, unknown> = { active: true };
    if (placement === 'home') {
      filter.placement = { $in: ['home', 'both'] };
    } else if (placement === 'products') {
      filter.placement = { $in: ['products', 'both'] };
    }
    const rows = await this.ads
      .find(filter)
      .sort({ sortOrder: 1, createdAt: -1 })
      .lean();
    return rows.map((row) => this.present(row));
  }

  async listAdmin(
    page = 1,
    limit = 20,
    query?: { placement?: string; search?: string; active?: string },
  ) {
    const filter: Record<string, unknown> = {};
    if (query?.placement) {
      filter.placement = query.placement;
    }
    if (query?.active === 'true') filter.active = true;
    if (query?.active === 'false') filter.active = false;
    if (query?.search) {
      const rx = new RegExp(query.search, 'i');
      filter.$or = [{ 'title.en': rx }, { 'title.ar': rx }, { link: rx }];
    }
    const [items, total] = await Promise.all([
      this.ads
        .find(filter)
        .sort({ sortOrder: 1, createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.ads.countDocuments(filter),
    ]);
    return {
      data: items.map((row) => this.present(row)),
      meta: paginationMeta(total, page, limit),
    };
  }

  async get(id: string) {
    const doc = await this.ads.findById(id).lean();
    if (!doc) throw new NotFoundException('Ad not found');
    return this.present(doc);
  }

  async create(dto: UpsertAdDto) {
    const doc = await this.ads.create(this.toDoc(dto));
    return this.present(doc.toObject());
  }

  async update(id: string, dto: UpsertAdDto) {
    const doc = await this.ads
      .findByIdAndUpdate(id, { $set: this.toDoc(dto) }, { new: true })
      .lean();
    if (!doc) throw new NotFoundException('Ad not found');
    return this.present(doc);
  }

  async remove(id: string) {
    const doc = await this.ads.findByIdAndDelete(id).lean();
    if (!doc) throw new NotFoundException('Ad not found');
    return { deleted: true };
  }

  private present(doc: unknown) {
    const rec = (doc ?? {}) as Record<string, unknown>;
    const title = (rec.title as { en?: string; ar?: string }) || {};
    const subtitle = (rec.subtitle as { en?: string; ar?: string }) || {};
    return {
      _id: String(rec._id ?? ''),
      id: String(rec._id ?? ''),
      image: String(rec.image ?? ''),
      title: { en: title.en || '', ar: title.ar || '' },
      subtitle: { en: subtitle.en || '', ar: subtitle.ar || '' },
      link: String(rec.link ?? ''),
      productId: rec.productId ? String(rec.productId) : '',
      categoryId: rec.categoryId ? String(rec.categoryId) : '',
      placement: String(rec.placement || 'home'),
      active: rec.active !== false,
      sortOrder: Number(rec.sortOrder ?? 0),
    };
  }

  private toDoc(dto: UpsertAdDto) {
    return {
      image: dto.image || '',
      title: { en: dto.title?.en || '', ar: dto.title?.ar || '' },
      subtitle: { en: dto.subtitle?.en || '', ar: dto.subtitle?.ar || '' },
      link: dto.link || '',
      productId: dto.productId ? new Types.ObjectId(dto.productId) : null,
      categoryId: dto.categoryId ? new Types.ObjectId(dto.categoryId) : null,
      placement: dto.placement || 'home',
      active: dto.active !== false,
      sortOrder: dto.sortOrder ?? 0,
    };
  }

  private async migrateFromConfig() {
    if ((await this.ads.countDocuments()) > 0) return;
    const cfg = await this.config.findOne({ key: 'global' }).lean();
    const banners = (cfg?.banners ?? []) as Record<string, unknown>[];
    const rows = banners
      .map((b, i) => {
        const title = (b.title as { en?: string; ar?: string }) || {};
        const subtitle = (b.subtitle as { en?: string; ar?: string }) || {};
        return {
          image: String(b.image ?? '').trim(),
          title: { en: title.en || '', ar: title.ar || '' },
          subtitle: { en: subtitle.en || '', ar: subtitle.ar || '' },
          link: String(b.link ?? ''),
          placement: ['home', 'products', 'both'].includes(String(b.placement))
            ? String(b.placement)
            : 'home',
          active: b.active !== false,
          sortOrder: Number(b.sortOrder ?? i),
        };
      })
      .filter((row) => row.image.length > 0);
    if (!rows.length) return;
    await this.ads.insertMany(rows);
  }
}
