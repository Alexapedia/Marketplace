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
    const doc = await this.configModel.findOne({ key: 'global' });
    if (!doc) {
      return this.configModel.create({
        key: 'global',
        banners: [],
        onboarding: [],
        version: {},
        settings: { deliveryFee: 0 },
      });
    }
    return doc;
  }

  async getPublic() {
    const doc = await this.getGlobal();
    return {
      banners: doc.banners,
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
    const doc = await this.configModel.findOneAndUpdate(
      { key: 'global' },
      { $set: patch },
      { new: true, upsert: true },
    );
    if (!doc) {
      throw new NotFoundException('App config not found');
    }
    return doc;
  }

  async deliveryFee(): Promise<number> {
    const doc = await this.getGlobal();
    const fee = Number(doc.settings?.deliveryFee ?? 0);
    return Number.isFinite(fee) ? fee : 0;
  }
}
