import { Injectable, inject, signal } from '@angular/core';
import { ApiClient } from '../api/api-client';
import { AppPublicConfig } from '../models/models';
import { normalizeCurrency } from './currency';

@Injectable({ providedIn: 'root' })
export class StoreConfigService {
  private readonly api = inject(ApiClient);
  readonly currency = signal('SAR');
  readonly brandName = signal('');
  readonly logo = signal('');
  readonly blocked = signal(false);
  readonly blockedKey = signal('maintenanceWebsite');

  constructor() {
    this.refresh();
  }

  refresh(): void {
    this.api.get<AppPublicConfig>('/app/config').subscribe({
      next: (res) => {
        const tenant = res.data?.tenant;
        this.currency.set(normalizeCurrency(res.data?.settings?.currency ?? tenant?.currency));
        const name = tenant?.branding?.name || tenant?.name || '';
        this.brandName.set(name);
        this.logo.set(tenant?.branding?.logo || '');
        if (name) document.title = name;
        const primary = tenant?.branding?.primary || '#071345';
        const accent = tenant?.branding?.accent || '#c9a45c';
        const root = document.documentElement;
        root.style.setProperty('--zz-navy', primary);
        root.style.setProperty('--zz-gold', accent);
        if (tenant?.branding?.favicon) {
          let link = document.querySelector<HTMLLinkElement>('link[rel="icon"]');
          if (!link) {
            link = document.createElement('link');
            link.rel = 'icon';
            document.head.appendChild(link);
          }
          link.href = tenant.branding.favicon;
        }
        if (tenant?.status === 'suspended') {
          this.blocked.set(true);
          this.blockedKey.set('maintenanceSuspended');
        } else if (tenant?.channels?.website === false) {
          this.blocked.set(true);
          this.blockedKey.set('maintenanceWebsite');
        } else {
          this.blocked.set(false);
        }
      },
      error: () => undefined,
    });
  }
}
