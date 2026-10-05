import { Pipe, PipeTransform, inject } from '@angular/core';
import { loc, Localized } from '../models/models';
import { I18nService } from './i18n.service';

@Pipe({ name: 't', pure: false })
export class TranslatePipe implements PipeTransform {
  private readonly i18n = inject(I18nService);

  transform(key: string): string {
    this.i18n.lang();
    return this.i18n.t(key);
  }
}

@Pipe({ name: 'loc', pure: false })
export class LocPipe implements PipeTransform {
  private readonly i18n = inject(I18nService);

  transform(value: Localized): string {
    return loc(value, this.i18n.lang());
  }
}
