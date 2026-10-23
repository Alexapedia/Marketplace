import { Component, computed, inject, signal } from '@angular/core';
import { DecimalPipe, DatePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformOverview } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { MatIconModule } from '@angular/material/icon';
import { MAISON } from '../../shared/maison';
import { HdAreaChart } from '../../shared/area-chart';

@Component({
  selector: 'app-overview-page',
  imports: [TranslatePipe, DecimalPipe, DatePipe, RouterLink, MatIconModule, MAISON, HdAreaChart],
  templateUrl: './overview-page.html',
  styleUrl: './overview-page.scss',
})
export class OverviewPage {
  private readonly api = inject(PlatformApi);
  readonly stats = signal<PlatformOverview | null>(null);
  readonly error = signal<string | null>(null);

  readonly orderValues = computed(() => (this.stats()?.series7 || []).map((p) => p.orders));
  readonly revenueValues = computed(() => (this.stats()?.series7 || []).map((p) => p.revenue));
  readonly days = computed(() => (this.stats()?.series7 || []).map((p) => p.day));
  readonly skeleton = [0, 1, 2, 3, 4, 5];
  readonly whole = (n: number): string => Math.round(n).toLocaleString('en-US');

  constructor() {
    this.api.overview().subscribe({
      next: (res) => this.stats.set(res.data),
      error: (err: Error) => this.error.set(err.message),
    });
  }
}
