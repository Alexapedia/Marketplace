import { Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslatePipe } from '../core/i18n/translate.pipe';

/** Loading / error-with-retry / empty block. Renders nothing once data is shown. */
@Component({
  selector: 'hd-state',
  imports: [MatProgressSpinnerModule, MatButtonModule, TranslatePipe],
  template: `
    @if (loading()) {
      <div class="st">
        <mat-spinner diameter="32" /><span>{{ 'common.loading' | t }}</span>
      </div>
    } @else if (error()) {
      <div class="st err" role="alert">
        <span>{{ error() }}</span>
        <button mat-stroked-button type="button" (click)="retry.emit()">
          {{ 'common.retry' | t }}
        </button>
      </div>
    } @else if (empty()) {
      <div class="st">
        <span>{{ emptyKey() | t }}</span>
      </div>
    }
  `,
  styles: `
    .st {
      display: grid;
      justify-items: center;
      gap: 12px;
      padding: 40px 16px;
      color: var(--zz-muted);
      text-align: center;
    }
    .err span {
      color: #be123c;
    }
  `,
})
export class HdState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyKey = input('common.empty');
  readonly retry = output<void>();
}
