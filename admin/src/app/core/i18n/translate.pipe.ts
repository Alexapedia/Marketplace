import { Pipe, PipeTransform, inject } from '@angular/core';
import { currencyLabel } from '../config/currency';
import { StoreConfigService } from '../config/store-config.service';
import { Localized, loc } from '../models/models';
import { I18nService } from './i18n.service';

@Pipe({ name: 't', pure: false })
export class TranslatePipe implements PipeTransform {
  private readonly i18n = inject(I18nService);
  private readonly store = inject(StoreConfigService);

  transform(key: string): string {
    this.i18n.lang();
    this.store.currency();
    if (key === 'currency' || key === 'dashboard.currency') {
      return currencyLabel(this.store.currency(), this.i18n.lang());
    }
    return this.i18n.t(key);
  }
}

@Pipe({ name: 'loc', pure: false })
export class LocPipe implements PipeTransform {
  private readonly i18n = inject(I18nService);

  transform(value: Localized | string | undefined | null): string {
    return loc(value, this.i18n.lang());
  }
}
