import { DecimalPipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { DashboardApi } from '../../core/api/dashboard.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { DashboardStats, num } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { errMessage } from '../../shared/ui.service';

@Component({
  selector: 'app-dashboard-page',
  imports: [MatCardModule, MatIconModule, DecimalPipe, TranslatePipe, AsyncState],
  templateUrl: './dashboard-page.html',
  styleUrl: './dashboard-page.scss',
})
export class DashboardPage implements OnInit {
  private readonly api = inject(DashboardApi);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly stats = signal<DashboardStats | null>(null);

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.get().subscribe({
      next: (res) => {
        this.stats.set(res.data ?? {});
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  value(keys: string[]): number {
    const data = this.stats() as Record<string, unknown> | null;
    if (!data) {
      return 0;
    }
    for (const key of keys) {
      if (typeof data[key] === 'number') {
        return data[key] as number;
      }
    }
    return 0;
  }

  bars(): Array<{ status: string; count: number; pct: number }> {
    const list = this.stats()?.ordersByStatus ?? this.stats()?.recent ?? [];
    const mapped = list.map((item) => {
      if ('status' in item) {
        return { status: String(item.status), count: num(item.count) };
      }
      const rec = item as { label?: string; value?: number };
      return { status: rec.label ?? '', count: num(rec.value) };
    });
    const max = Math.max(...mapped.map((b) => b.count), 1);
    return mapped.map((b) => ({ ...b, pct: Math.round((b.count / max) * 100) }));
  }

  cards() {
    return [
      { key: 'dashboard.orders', icon: 'receipt_long', value: this.value(['orders', 'ordersCount']) },
      {
        key: 'dashboard.pendingCustom',
        icon: 'pending_actions',
        value: this.value(['pendingCustomOrders', 'pendingCustom']),
      },
      { key: 'dashboard.revenue', icon: 'payments', value: this.value(['revenue']), money: true },
      { key: 'dashboard.products', icon: 'inventory_2', value: this.value(['products', 'productsCount']) },
      {
        key: 'dashboard.customers',
        icon: 'group',
        value: this.value(['customers', 'customersCount', 'newCustomers']),
      },
      {
        key: 'dashboard.unreadChats',
        icon: 'mark_chat_unread',
        value: this.value(['unreadChats', 'unreadChatCount']),
      },
    ];
  }
}
