import { DatePipe } from '@angular/common';
import { Component, inject, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { PagedList } from '../../core/api/paged-list';
import { I18nService } from '../../core/i18n/i18n.service';
import { Order } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { LoadMore } from '../../shared/load-more';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-orders-page',
  imports: [RouterLink, DatePipe, PageBar, TranslatePipe, AsyncState, LoadMore, Icon, MAISON],
  templateUrl: './orders-page.html',
})
export class OrdersPage implements OnInit {
  readonly i18n = inject(I18nService);
  readonly list = new PagedList<Order>(inject(ApiClient), '/orders');

  ngOnInit(): void {
    this.list.reload();
  }

  statusLabel(status: string): string {
    return this.i18n.t(`status_${status}`);
  }
}
