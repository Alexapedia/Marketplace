import { Injectable, inject, signal } from '@angular/core';
import { AppConfigApi } from '../api/app-config.api';
import { normalizeCurrency } from './currency';

@Injectable({ providedIn: 'root' })
export class StoreConfigService {
  private readonly api = inject(AppConfigApi);
  readonly currency = signal('SAR');

  constructor() {
    this.refresh();
  }

  refresh(): void {
    this.api.get().subscribe({
      next: (res) => {
        this.currency.set(normalizeCurrency(String(res.data?.settings?.['currency'] ?? 'SAR')));
      },
      error: () => undefined,
    });
  }

  setCurrency(code: string): void {
    this.currency.set(normalizeCurrency(code));
  }
}
