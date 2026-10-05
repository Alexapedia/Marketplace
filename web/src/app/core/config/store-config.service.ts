import { Injectable, inject, signal } from '@angular/core';
import { ApiClient } from '../api/api-client';
import { AppPublicConfig } from '../models/models';
import { normalizeCurrency } from './currency';

@Injectable({ providedIn: 'root' })
export class StoreConfigService {
  private readonly api = inject(ApiClient);
  readonly currency = signal('SAR');

  constructor() {
    this.refresh();
  }

  refresh(): void {
    this.api.get<AppPublicConfig>('/app/config').subscribe({
      next: (res) => {
        this.currency.set(normalizeCurrency(res.data?.settings?.currency));
      },
      error: () => undefined,
    });
  }
}
