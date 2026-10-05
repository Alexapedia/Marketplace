import { DecimalPipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { RouterLink } from '@angular/router';
import { ReportsApi } from '../../core/api/reports.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { loc, Localized, num, productRef, ReportsData } from '../../core/models/models';
import { I18nService } from '../../core/i18n/i18n.service';
import { AsyncState } from '../../shared/async-state';
import { errMessage } from '../../shared/ui.service';

@Component({
  selector: 'app-reports-page',
  imports: [
    DecimalPipe,
    FormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatCardModule,
    TranslatePipe,
    AsyncState,
    RouterLink,
  ],
  templateUrl: './reports-page.html',
  styleUrl: './reports-page.scss',
})
export class ReportsPage implements OnInit {
  private readonly api = inject(ReportsApi);
  readonly i18n = inject(I18nService);
  readonly productRef = productRef;

  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly data = signal<ReportsData | null>(null);
  from = this.isoDaysAgo(30);
  to = this.isoDaysAgo(0);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.get(this.from, this.to).subscribe({
      next: (res) => {
        this.data.set(res.data ?? {});
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  bars(list: Array<{ status?: string; reason?: string; _id?: string; channel?: string; count?: number }> | undefined) {
    const mapped = (list ?? []).map((i) => ({
      label: String(i.status ?? i.reason ?? i.channel ?? i._id ?? ''),
      count: num(i.count),
    }));
    const max = Math.max(...mapped.map((b) => b.count), 1);
    return mapped.map((b) => ({ ...b, pct: Math.round((b.count / max) * 100) }));
  }

  customBars() {
    const raw = this.data()?.customStats;
    if (Array.isArray(raw)) {
      return this.bars(raw);
    }
    return this.bars(
      Object.entries(raw ?? {}).map(([status, count]) => ({ status, count: Number(count) })),
    );
  }

  productName(name: Localized | string | undefined): string {
    return loc(name, this.i18n.lang());
  }

  text(value: Localized | string | undefined): string {
    return loc(value, this.i18n.lang());
  }

  private isoDaysAgo(days: number): string {
    const d = new Date();
    d.setDate(d.getDate() - days);
    return d.toISOString().slice(0, 10);
  }
}
