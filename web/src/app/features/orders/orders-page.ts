import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { I18nService } from '../../core/i18n/i18n.service';
import { asItems, Order } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-orders-page',
  imports: [RouterLink, PageBar, TranslatePipe],
  templateUrl: './orders-page.html',
})
export class OrdersPage implements OnInit {
  private readonly api = inject(ApiClient);
  readonly i18n = inject(I18nService);

  orders = signal<Order[]>([]);

  ngOnInit(): void {
    this.api.get<Order[]>('/orders').subscribe({
      next: (res) => this.orders.set(asItems<Order>(res.data)),
    });
  }

  statusLabel(status: string): string {
    return this.i18n.t(`status_${status}`) || status;
  }
}
