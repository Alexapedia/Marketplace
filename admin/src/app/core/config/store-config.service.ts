import { Injectable, computed, inject, signal } from '@angular/core';
import { ApiClient } from '../api/api-client';
import { TenantPublic } from '../models/models';
import { normalizeCurrency } from './currency';

@Injectable({ providedIn: 'root' })
export class StoreConfigService {
  private readonly api = inject(ApiClient);
  readonly currency = signal('SAR');
  readonly brandName = signal('');
  readonly logo = signal('');
  readonly blocked = signal(false);
  readonly blockedKey = signal('maintenance.admin');
  readonly mark = computed(() => (this.brandName() || 'Z').charAt(0).toUpperCase());

  constructor() {
    this.refresh();
  }

  refresh(): void {
    this.api.get<{ settings?: Record<string, unknown>; tenant?: TenantPublic }>('/app/config').subscribe({
      next: (res) => {
        const tenant = res.data?.tenant;
        const currency = String(res.data?.settings?.['currency'] ?? tenant?.currency ?? 'SAR');
        this.currency.set(normalizeCurrency(currency));
        if (tenant) {
          this.applyTenant(tenant);
        }
      },
      error: () => undefined,
    });
  }

  setCurrency(code: string): void {
    this.currency.set(normalizeCurrency(code));
  }

  private applyTenant(tenant: TenantPublic): void {
    const name = tenant.branding?.name || tenant.name || '';
    this.brandName.set(name);
    this.logo.set(tenant.branding?.logo || '');
    if (name) {
      document.title = `${name} Admin`;
    }
    const primary = tenant.branding?.primary || '#071345';
    const accent = tenant.branding?.accent || '#c9a45c';
    const root = document.documentElement;
    root.style.setProperty('--zz-navy', primary);
    root.style.setProperty('--pm-ink', primary);
    root.style.setProperty('--pm-sidebar', primary);
    root.style.setProperty('--pm-gold', accent);
    root.style.setProperty('--zz-gold', accent);
    if (tenant.branding?.favicon) {
      let link = document.querySelector<HTMLLinkElement>('link[rel="icon"]');
      if (!link) {
        link = document.createElement('link');
        link.rel = 'icon';
        document.head.appendChild(link);
      }
      link.href = tenant.branding.favicon;
    }
    if (tenant.status === 'suspended') {
      this.blocked.set(true);
      this.blockedKey.set('maintenance.suspended');
    } else if (tenant.channels?.admin === false) {
      this.blocked.set(true);
      this.blockedKey.set('maintenance.admin');
    } else {
      this.blocked.set(false);
    }
  }
}
