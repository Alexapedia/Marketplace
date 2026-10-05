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

@Component({
  selector: 'app-order-detail-page',
  imports: [DatePipe, RouterLink, FormsModule, PageBar, OrderTimeline, Stars, TranslatePipe],
  templateUrl: './order-detail-page.html',
})
export class OrderDetailPage implements OnInit {
  private readonly api = inject(ApiClient);
  private readonly route = inject(ActivatedRoute);
  readonly i18n = inject(I18nService);
  private readonly toast = inject(ToastService);

  order = signal<Order | null>(null);
  rating = 5;
  comment = '';
  readonly media = media;

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      const id = params.get('id') || '';
      this.api.get<Order>(`/orders/${id}`).subscribe({
        next: (res) => this.order.set(res.data),
      });
    });
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

  cancel(): void {
    const id = this.route.snapshot.paramMap.get('id') || '';
    if (!confirm(this.i18n.t('cancelOrderConfirm'))) return;
    this.api.post(`/orders/${id}/cancel`, {}).subscribe({
      next: () => {
        this.toast.show(this.i18n.t('orderCancelled'));
        this.api.get<Order>(`/orders/${id}`).subscribe({
          next: (res) => this.order.set(res.data),
        });
      },
      error: (e) => this.toast.show(e.message),
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
          this.api.get<Order>(`/orders/${id}`).subscribe({
            next: (res) => this.order.set(res.data),
          });
        },
        error: (e) => this.toast.show(e.message),
      });
  }
}
