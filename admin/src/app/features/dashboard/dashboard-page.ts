import { DatePipe, DecimalPipe } from '@angular/common';
import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DashboardApi } from '../../core/api/dashboard.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { DashboardStats, num } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { errMessage } from '../../shared/ui.service';

const STATUS_ORDER = [
  'pending',
  'accepted',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'completed',
  'cancelled',
  'rejected',
];

@Component({
  selector: 'app-dashboard-page',
  imports: [DatePipe, DecimalPipe, RouterLink, TranslatePipe, AsyncState],
  templateUrl: './dashboard-page.html',
  styleUrl: './dashboard-page.scss',
})
export class DashboardPage implements OnInit {
  private readonly api = inject(DashboardApi);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly stats = signal<DashboardStats | null>(null);
  readonly now = new Date();

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

  n(keys: string[]): number {
    const data = this.stats() as Record<string, unknown> | null;
    if (!data) return 0;
    for (const key of keys) {
      if (typeof data[key] === 'number') return data[key] as number;
    }
    return 0;
  }

  readonly view = computed(() => {
    const s = this.stats();
    const orders = this.n(['orders', 'ordersCount']);
    const revenue = this.n(['revenue']);
    const profit = this.n(['profit']);
    const products = this.n(['products', 'productsCount']);
    const customers = this.n(['customers', 'customersCount']);
    const active = this.n(['activeCustomers']);
    const blocked = this.n(['inactiveCustomers']);
    const published = this.n(['publishedProducts']);
    const unpublished = this.n(['unpublishedProducts']);
    const pendingCustom = this.n(['pendingCustom', 'pendingCustomOrders']);
    const visitsMobile = s?.visits?.visitsMobile ?? 0;
    const visitsWebsite = s?.visits?.visitsWebsite ?? 0;
    const visits = visitsMobile + visitsWebsite;
    const delivered = this.statusCount(['delivered', 'completed']);
    const open = Math.max(orders - delivered - this.statusCount(['cancelled', 'rejected']), 0);
    const fulfillment = this.pct(delivered, orders);
    const conversion = this.pct(orders, visits);
    const activePct = this.pct(active, customers);
    const publishedPct = this.pct(published, products);
    const series = s?.series ?? [];
    return {
      orders,
      revenue,
      profit,
      products,
      customers,
      active,
      blocked,
      published,
      unpublished,
      pendingCustom,
      visitsMobile,
      visitsWebsite,
      visits,
      delivered,
      open,
      fulfillment,
      conversion,
      activePct,
      publishedPct,
      lowStock: this.n(['lowStock']),
      unread: this.n(['unreadChats', 'unreadChatCount']),
      newCustomers: this.n(['newCustomers']),
      trendOrders: s?.trend?.orders ?? 0,
      trendRevenue: s?.trend?.revenue ?? 0,
      series,
      area: this.chart(series.map((d) => d.revenue || d.orders)),
      pipeline: this.ranked(s?.ordersByStatus ?? [], 'status', STATUS_ORDER),
      custom: this.ranked(s?.customOrdersByStatus ?? [], 'status'),
      channels: this.ranked(s?.ordersByChannel ?? [], 'channel'),
      productsTop: (s?.topProducts ?? []).slice(0, 6),
    };
  });

  label(value: string): string {
    const key = `dashboard.st.${value}`;
    const translated = this.i18n.t(key);
    return translated === key ? value.replaceAll('_', ' ') : translated;
  }

  pct(part: number, total: number): number {
    if (!total) return 0;
    return Math.round((part / total) * 100);
  }

  dash(pct: number): string {
    const c = 2 * Math.PI * 42;
    const p = Math.max(0, Math.min(pct, 100));
    return `${(p / 100) * c} ${c}`;
  }

  private statusCount(names: string[]): number {
    return (this.stats()?.ordersByStatus ?? [])
      .filter((row) => names.includes(row.status))
      .reduce((sum, row) => sum + num(row.count), 0);
  }

  private ranked(
    list: Array<{ status?: string; channel?: string; count?: number; revenue?: number }>,
    key: 'status' | 'channel',
    order?: string[],
  ) {
    const mapped = list.map((item) => ({
      label: String(item[key] ?? ''),
      count: num(item.count),
      revenue: num(item.revenue),
    }));
    if (order) {
      mapped.sort((a, b) => {
        const ai = order.indexOf(a.label);
        const bi = order.indexOf(b.label);
        return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi);
      });
    } else {
      mapped.sort((a, b) => b.count - a.count);
    }
    const max = Math.max(...mapped.map((b) => b.count), 1);
    return mapped.map((b) => ({ ...b, pct: Math.round((b.count / max) * 100) }));
  }

  private chart(values: number[]) {
    const w = 560;
    const h = 128;
    if (!values.length) {
      return { line: `M0 ${h} L${w} ${h}`, area: `M0 ${h} L${w} ${h} Z`, w, h };
    }
    const max = Math.max(...values, 1);
    const step = w / Math.max(values.length - 1, 1);
    const pts = values.map((v, i) => {
      const x = i * step;
      const y = h - 8 - (v / max) * (h - 18);
      return { x, y };
    });
    const line = pts.map((p, i) => `${i ? 'L' : 'M'}${p.x.toFixed(1)} ${p.y.toFixed(1)}`).join(' ');
    const area = `${line} L${w} ${h} L0 ${h} Z`;
    return { line, area, w, h };
  }
}
