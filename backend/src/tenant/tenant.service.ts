import {
  ConflictException,
  Injectable,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Tenant, TenantDocument } from '../schemas/tenant.schema';
import { AppChannel } from './tenant.context';

@Injectable()
export class TenantService {
  constructor(
    @InjectModel(Tenant.name) private readonly tenants: Model<TenantDocument>,
    private readonly config: ConfigService,
  ) {}

  normalizeHost(raw?: string): string {
    if (!raw) return '';
    try {
      if (raw.includes('://')) {
        return new URL(raw).host.toLowerCase();
      }
    } catch {
      /* ignore */
    }
    return raw.split('/')[0].toLowerCase();
  }

  async findById(id: string) {
    return this.tenants.findById(id);
  }

  async findBySlug(slug: string) {
    return this.tenants.findOne({ slug: slug.toLowerCase() });
  }

  async findByHost(host: string) {
    const normalized = this.normalizeHost(host);
    if (!normalized) return null;
    return this.tenants.findOne({ 'domains.host': normalized });
  }

  async resolveFromRequest(input: {
    origin?: string;
    referer?: string;
    host?: string;
    client?: string;
    path?: string;
  }): Promise<{
    tenant: TenantDocument;
    channel: AppChannel;
  } | null> {
    const client = String(input.client || '').toLowerCase();
    let channel: AppChannel | undefined;
    if (client === 'admin' || client === 'website' || client === 'mobile') {
      channel = client;
    }

    const hosts = [
      this.normalizeHost(input.origin),
      this.normalizeHost(input.referer),
      this.normalizeHost(input.host),
    ].filter(Boolean);

    for (const host of hosts) {
      const tenant = await this.findByHost(host);
      if (tenant) {
        const mapped = tenant.domains.find((d) => d.host === host);
        return {
          tenant,
          channel: channel || (mapped?.channel as AppChannel) || 'website',
        };
      }
    }

    const fallback = this.config.get<string>('DEFAULT_TENANT_SLUG') || 'zezo';
    const tenant = await this.findBySlug(fallback);
    if (!tenant) return null;
    if (!channel) {
      if (input.path?.includes('/admin')) channel = 'admin';
      else channel = 'website';
    }
    return { tenant, channel };
  }

  assertChannel(tenant: TenantDocument, channel: AppChannel): void {
    if (tenant.status === 'suspended') {
      throw new ServiceUnavailableException('This store is suspended');
    }
    const enabled = tenant.channels?.[channel] !== false;
    if (!enabled) {
      throw new ServiceUnavailableException(
        channel === 'admin'
          ? 'Admin is temporarily disabled'
          : channel === 'mobile'
            ? 'The mobile app is temporarily disabled'
            : 'The website is temporarily disabled',
      );
    }
  }

  async list() {
    return this.tenants.find().sort({ createdAt: -1 }).lean();
  }

  async create(input: {
    slug: string;
    name: string;
    domains?: Array<{ host: string; channel: 'website' | 'admin' }>;
    branding?: Partial<Tenant['branding']>;
    currency?: string;
  }) {
    const slug = input.slug.toLowerCase().trim();
    const exists = await this.tenants.findOne({ slug });
    if (exists) {
      throw new ConflictException('Slug already used');
    }
    for (const domain of input.domains ?? []) {
      const taken = await this.findByHost(domain.host);
      if (taken) {
        throw new ConflictException(`Domain already used: ${domain.host}`);
      }
    }
    return this.tenants.create({
      slug,
      name: input.name.trim(),
      status: 'active',
      domains: (input.domains ?? []).map((d) => ({
        host: this.normalizeHost(d.host),
        channel: d.channel,
      })),
      channels: { website: true, admin: true, mobile: true },
      branding: {
        name: input.branding?.name || input.name,
        primary: input.branding?.primary || '#071345',
        accent: input.branding?.accent || '#c9a45c',
        logo: input.branding?.logo || '',
        logoDark: input.branding?.logoDark || '',
        favicon: input.branding?.favicon || '',
        splash: input.branding?.splash || '',
      },
      currency: input.currency || 'SAR',
    });
  }

  async update(id: string, patch: Record<string, unknown>) {
    if (patch['domains']) {
      const domains = patch['domains'] as Array<{ host: string; channel: string }>;
      patch['domains'] = domains.map((d) => ({
        host: this.normalizeHost(d.host),
        channel: d.channel,
      }));
    }
    if (patch['branding'] && typeof patch['branding'] === 'object') {
      const current = await this.tenants.findById(id);
      patch['branding'] = {
        ...(current?.branding ? current.branding : {}),
        ...(patch['branding'] as Record<string, unknown>),
      };
    }
    const doc = await this.tenants.findByIdAndUpdate(id, { $set: patch }, { new: true });
    if (!doc) throw new NotFoundException('Tenant not found');
    return doc;
  }

  async setChannel(id: string, channel: AppChannel, enabled: boolean) {
    const doc = await this.tenants.findByIdAndUpdate(
      id,
      { $set: { [`channels.${channel}`]: enabled } },
      { new: true },
    );
    if (!doc) throw new NotFoundException('Tenant not found');
    return doc;
  }

  async setStatus(id: string, status: 'active' | 'suspended') {
    const doc = await this.tenants.findByIdAndUpdate(id, { $set: { status } }, { new: true });
    if (!doc) throw new NotFoundException('Tenant not found');
    return doc;
  }

  async ensureDefault(): Promise<TenantDocument> {
    const slug = (this.config.get<string>('DEFAULT_TENANT_SLUG') || 'zezo').toLowerCase();
    const existing = await this.tenants.findOne({ slug });
    if (existing) return existing;
    return this.tenants.create({
      slug,
      name: 'Zezo Store',
      status: 'active',
      domains: [
        { host: 'localhost:5173', channel: 'website' },
        { host: '127.0.0.1:5173', channel: 'website' },
        { host: 'localhost:4200', channel: 'admin' },
        { host: '127.0.0.1:4200', channel: 'admin' },
      ],
      channels: { website: true, admin: true, mobile: true },
      branding: {
        name: 'Zezo Store',
        primary: '#071345',
        accent: '#c9a45c',
        logo: '',
        logoDark: '',
        favicon: '',
        splash: '',
      },
      currency: 'SAR',
    });
  }

  publicView(tenant: TenantDocument | Record<string, unknown>) {
    const doc = tenant as Tenant;
    return {
      id: String((tenant as { _id?: unknown })._id ?? ''),
      slug: doc.slug,
      name: doc.name,
      status: doc.status,
      channels: {
        website: doc.channels?.website !== false,
        admin: doc.channels?.admin !== false,
        mobile: doc.channels?.mobile !== false,
      },
      branding: {
        name: doc.branding?.name || doc.name,
        primary: doc.branding?.primary || '#071345',
        accent: doc.branding?.accent || '#c9a45c',
        logo: doc.branding?.logo || '',
        logoDark: doc.branding?.logoDark || '',
        favicon: doc.branding?.favicon || '',
        splash: doc.branding?.splash || '',
      },
      currency: doc.currency || 'SAR',
    };
  }
}
