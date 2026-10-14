import { Component, input, output } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-load-more',
  imports: [TranslatePipe],
  template: `
    @if (show()) {
      <div class="load-more">
        <button class="btn navy" type="button" [disabled]="busy()" (click)="more.emit()">
          {{ (busy() ? 'loading' : 'loadMore') | t }}
        </button>
      </div>
    }
  `,
})
export class LoadMore {
  readonly show = input(false);
  readonly busy = input(false);
  readonly more = output<void>();
}
