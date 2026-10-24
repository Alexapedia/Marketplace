import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { ApiClient } from '../../core/api/api-client';
import { I18nService } from '../../core/i18n/i18n.service';
import { media, Order, OrderItem, pid } from '../../core/models/models';
import { OrderTimeline } from '../../shared/order-timeline';
import { PageBar } from '../../shared/page-bar';
import { Stars } from '../../shared/stars';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { ToastService } from '../../core/toast/toast.service';
import { DialogService } from '../../core/dialog/dialog.service';
import { AsyncState } from '../../shared/async-state';
import { PriceSummary } from '../../shared/price-summary';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-order-detail-page',
  imports: [DatePipe, RouterLink, FormsModule, PageBar, OrderTimeline, Stars, TranslatePipe, AsyncState, PriceSummary, Icon, MAISON],
  templateUrl: './order-detail-page.html',
})
export class OrderDetailPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  readonly i18n = inject(I18nService);
  private readonly toast = inject(ToastService);
  private readonly dialog = inject(DialogService);

  order = signal<Order | null>(null);
  loading = signal(true);
  error = signal<string | null>(null);
  busy = signal(false);
  rating = 5;
  comment = '';
  readonly media = media;

  ngOnInit(): void {
    this.route.paramMap.subscribe(() => this.load());
  }

  load(): void {
    const id = this.route.snapshot.paramMap.get('id') || '';
    this.loading.set(true);
    this.error.set(null);
    this.api.get<Order>(`/orders/${id}`).subscribe({
      next: (res) => {
        this.order.set(res.data);
        this.loading.set(false);
      },
      error: (e: Error) => {
        this.error.set(e.message);
        this.loading.set(false);
      },
    });
  }

  statusLabel(): string {
    return this.i18n.t(`status_${this.status()}`);
  }

  subtotal(o: Order): number {
    return o.subtotal ?? (o.items ?? []).reduce((n, i) => n + (i.unitPrice ?? 0) * (i.quantity ?? 1), 0);
  }

  status(): string {
    return this.order()?.orderStatus || this.order()?.status || 'pending';
  }

  canCancel(): boolean {
    const s = this.status();
    return s === 'pending' || s === 'accepted';
  }

  canRate(): boolean {
    const s = this.status();
    return (s === 'delivered' || s === 'completed') && !this.order()?.rating;
  }

  itemPid(item: OrderItem): string {
    const p = item.productId;
    if (!p) return '';
    if (typeof p === 'string') return p;
    return pid(p);
  }

  async cancel(): Promise<void> {
    const id = this.route.snapshot.paramMap.get('id') || '';
    const ok = await this.dialog.confirm({
      title: 'cancelOrder',
      message: 'cancelOrderConfirm',
      confirmKey: 'cancelOrder',
      danger: true,
    });
    if (!ok || this.busy()) return;
    this.busy.set(true);
    this.api.post(`/orders/${id}/cancel`, {}).subscribe({
      next: () => {
        this.busy.set(false);
        this.toast.show(this.i18n.t('orderCancelled'));
        this.load();
      },
      error: (e) => {
        this.busy.set(false);
        this.toast.show(e.message);
      },
    });
  }

  submitRating(ev: Event): void {
    ev.preventDefault();
    const id = this.route.snapshot.paramMap.get('id') || '';
    this.api
      .post('/reviews', {
        targetType: 'order',
        targetId: id,
        rating: this.rating,
        comment: this.comment,
      })
      .subscribe({
        next: () => {
          this.toast.show(this.i18n.t('thanksRating'));
          this.load();
        },
        error: (e) => this.toast.show(e.message),
      });
  }
}
