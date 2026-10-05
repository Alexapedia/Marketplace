import { Component, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { I18nService } from '../../core/i18n/i18n.service';
import { asItems, Category, CustomOrder, loc, pid } from '../../core/models/models';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

@Component({
  selector: 'app-custom-list-page',
  imports: [RouterLink, PageBar, TranslatePipe],
  templateUrl: './custom-list-page.html',
})
export class CustomListPage implements OnInit {
  private readonly api = inject(ApiClient);
  readonly i18n = inject(I18nService);

  orders = signal<CustomOrder[]>([]);

  ngOnInit(): void {
    this.api.get<CustomOrder[]>('/custom-orders').subscribe({
      next: (res) => this.orders.set(asItems<CustomOrder>(res.data)),
    });
  }

  title(o: CustomOrder): string {
    const cat = o.categoryId;
    if (cat && typeof cat === 'object') {
      const label = loc((cat as Category).names ?? (cat as Category).name, this.i18n.lang());
      if (label) return label;
    }
    const id = String(o._id || '');
    return id ? `#${id.slice(-8)}` : this.i18n.t('customOrders');
  }
}
