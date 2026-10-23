import { DatePipe } from '@angular/common';
import { Component, inject, OnInit } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ApiClient } from '../../core/api/api-client';
import { PagedList } from '../../core/api/paged-list';
import { I18nService } from '../../core/i18n/i18n.service';
import { Category, CustomOrder, loc } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { LoadMore } from '../../shared/load-more';
import { PageBar } from '../../shared/page-bar';
import { TranslatePipe } from '../../core/i18n/translate.pipe';

import { Icon } from '../../shared/icon';
import { MAISON } from '../../shared/maison';

@Component({
  selector: 'app-custom-list-page',
  imports: [RouterLink, DatePipe, PageBar, TranslatePipe, AsyncState, LoadMore, Icon, MAISON],
  templateUrl: './custom-list-page.html',
})
export class CustomListPage implements OnInit {
  readonly i18n = inject(I18nService);
  readonly list = new PagedList<CustomOrder>(inject(ApiClient), '/custom-orders');

  ngOnInit(): void {
    this.list.reload();
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
