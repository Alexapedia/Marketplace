import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AppConfig, AppConfigDocument } from '../schemas/app-config.schema';

@Injectable()
export class AppConfigService {
  constructor(
    @InjectModel(AppConfig.name)
    private readonly configModel: Model<AppConfigDocument>,
  ) {}

  async getGlobal() {
    const doc = await this.configModel.findOne({ key: 'global' }).lean();
    if (!doc) {
      const created = await this.configModel.create({
        key: 'global',
        banners: [],
        onboarding: [],
        version: {},
        settings: {
          deliveryFee: 0,
          currency: 'SAR',
          supportPhone: '',
          supportEmail: '',
        },
      });
      return created.toObject();
    }
    return doc;
  }

  async getPublic() {
    const doc = await this.getGlobal();
    const banners = (doc.banners ?? []).filter((item) => {
      const banner = item as Record<string, unknown>;
      return banner['active'] !== false;
    });
    return {
      banners,
      onboarding: doc.onboarding,
      settings: doc.settings,
    };
  }

  async getVersion(platform?: string) {
    const doc = await this.getGlobal();
    const version = doc.version ?? {};
    if (platform === 'ios') {
      return version.ios ?? null;
    }
    if (platform === 'android') {
      return version.android ?? null;
    }
    return version;
  }

  async update(patch: Record<string, unknown>) {
    const current = await this.getGlobal();
    const set: Record<string, unknown> = { ...patch };
    if (patch.settings && typeof patch.settings === 'object') {
      set.settings = {
        ...(current.settings ?? {}),
        ...(patch.settings as Record<string, unknown>),
      };
    }
    const doc = await this.configModel.findOneAndUpdate(
      { key: 'global' },
      { $set: set },
      { new: true, upsert: true },
    );
    if (!doc) {
      throw new NotFoundException('App config not found');
    }
    return doc.toObject();
  }

  async deliveryFee(): Promise<number> {
    const doc = await this.getGlobal();
    const fee = Number(doc.settings?.deliveryFee ?? 0);
    return Number.isFinite(fee) ? fee : 0;
  }
}
