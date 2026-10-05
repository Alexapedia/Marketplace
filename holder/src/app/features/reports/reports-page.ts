import { Component, computed, inject, signal } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformReports } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { areaPath, barPct } from '../../core/chart';

@Component({
  selector: 'app-reports-page',
  imports: [TranslatePipe, DecimalPipe, RouterLink],
  templateUrl: './reports-page.html',
  styleUrl: './reports-page.scss',
})
export class ReportsPage {
  private readonly api = inject(PlatformApi);
  readonly data = signal<PlatformReports | null>(null);
  readonly error = signal<string | null>(null);

  readonly orderSpark = computed(() =>
    areaPath((this.data()?.series14 || []).map((p) => p.orders), 640, 132),
  );
  readonly revSpark = computed(() =>
    areaPath((this.data()?.series14 || []).map((p) => p.revenue), 640, 132),
  );
  readonly visitSpark = computed(() =>
    areaPath((this.data()?.series14 || []).map((p) => p.visits || 0), 360, 96),
  );
  readonly crashSpark = computed(() =>
    areaPath((this.data()?.series14 || []).map((p) => p.crashes || 0), 360, 96),
  );
  readonly statusMax = computed(() =>
    Math.max(1, ...(this.data()?.ordersByStatus || []).map((r) => r.count)),
  );
  readonly revMax = computed(() =>
    Math.max(1, ...(this.data()?.revenueByTenant || []).map((r) => r.revenue)),
  );
  readonly visitMax = computed(() =>
    Math.max(1, ...(this.data()?.visitsByPlatform || []).map((r) => r.count)),
  );
  readonly issueMax = computed(() =>
    Math.max(1, ...(this.data()?.issuesByChannel || []).map((r) => r.count)),
  );

  readonly totals = computed(() => {
    const series = this.data()?.series14 || [];
    return {
      orders: series.reduce((n, p) => n + p.orders, 0),
      revenue: series.reduce((n, p) => n + p.revenue, 0),
      visits: series.reduce((n, p) => n + (p.visits || 0), 0),
      crashes: series.reduce((n, p) => n + (p.crashes || 0), 0),
    };
  });

  constructor() {
    this.api.reports().subscribe({
      next: (res) => this.data.set(res.data),
      error: (err: Error) => this.error.set(err.message),
    });
  }

  pct(value: number, max: number): number {
    return barPct(value, max);
  }
}
