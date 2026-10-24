import { Component, computed, inject, signal } from '@angular/core';
import { DecimalPipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformReports } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { barPct } from '../../core/chart';
import { MatIconModule } from '@angular/material/icon';
import { MAISON } from '../../shared/maison';
import { HdAreaChart } from '../../shared/area-chart';

@Component({
  selector: 'app-reports-page',
  imports: [TranslatePipe, DecimalPipe, RouterLink, MatIconModule, MAISON, HdAreaChart],
  templateUrl: './reports-page.html',
  styleUrl: './reports-page.scss',
})
export class ReportsPage {
  private readonly api = inject(PlatformApi);
  readonly data = signal<PlatformReports | null>(null);
  readonly error = signal<string | null>(null);

  private readonly series = computed(() => this.data()?.series14 || []);
  readonly orderValues = computed(() => this.series().map((p) => p.orders));
  readonly revenueValues = computed(() => this.series().map((p) => p.revenue));
  readonly visitValues = computed(() => this.series().map((p) => p.visits || 0));
  readonly crashValues = computed(() => this.series().map((p) => p.crashes || 0));
  readonly days = computed(() => this.series().map((p) => p.day));
  readonly skeleton = [0, 1, 2, 3];
  readonly whole = (n: number): string => Math.round(n).toLocaleString('en-US');
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
