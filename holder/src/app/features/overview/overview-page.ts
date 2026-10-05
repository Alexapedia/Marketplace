import { Component, computed, inject, signal } from '@angular/core';
import { DecimalPipe, DatePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PlatformApi } from '../../core/api/platform.api';
import { PlatformOverview } from '../../core/models/models';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { areaPath } from '../../core/chart';

@Component({
  selector: 'app-overview-page',
  imports: [TranslatePipe, DecimalPipe, DatePipe, RouterLink],
  templateUrl: './overview-page.html',
  styleUrl: './overview-page.scss',
})
export class OverviewPage {
  private readonly api = inject(PlatformApi);
  readonly stats = signal<PlatformOverview | null>(null);
  readonly error = signal<string | null>(null);

  readonly spark = computed(() => areaPath((this.stats()?.series7 || []).map((p) => p.orders)));
  readonly revSpark = computed(() => areaPath((this.stats()?.series7 || []).map((p) => p.revenue)));

  constructor() {
    this.api.overview().subscribe({
      next: (res) => this.stats.set(res.data),
      error: (err: Error) => this.error.set(err.message),
    });
  }
}
