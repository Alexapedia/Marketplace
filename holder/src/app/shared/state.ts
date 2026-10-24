import { Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TranslatePipe } from '../core/i18n/translate.pipe';

/** Skeleton loading / error-with-retry / empty block. Renders nothing once data is shown. */
@Component({
  selector: 'hd-state',
  imports: [MatButtonModule, MatIconModule, TranslatePipe],
  template: `
    @if (loading()) {
      <div class="sk" [attr.aria-label]="'common.loading' | t" role="status" aria-busy="true">
        @for (i of rows; track i) {
          <div class="sk-row">
            <span class="hd-sk dot"></span>
            <span class="lines">
              <span class="hd-sk l1"></span>
              <span class="hd-sk l2"></span>
            </span>
          </div>
        }
      </div>
    } @else if (error()) {
      <div class="st err m-enter" role="alert">
        <span class="ic"><mat-icon>cloud_off</mat-icon></span>
        <strong>{{ 'common.error' | t }}</strong>
        <span class="msg">{{ error() }}</span>
        <button mat-stroked-button type="button" (click)="retry.emit()">
          <mat-icon>refresh</mat-icon>{{ 'common.retry' | t }}
        </button>
      </div>
    } @else if (empty()) {
      <div class="st m-enter">
        <span class="ic"><mat-icon>{{ icon() }}</mat-icon></span>
        <span class="msg">{{ emptyKey() | t }}</span>
      </div>
    }
  `,
  styles: `
    .sk {
      display: grid;
      gap: 12px;
    }
    .sk-row {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 20px 24px;
      border-radius: var(--m-r-lg);
      border: 1px solid var(--m-line);
      background: var(--m-surface);
    }
    .dot {
      width: 44px;
      height: 44px;
      border-radius: var(--m-r-sm);
      flex: none;
    }
    .lines {
      flex: 1;
      display: grid;
      gap: 10px;
    }
    .l1 {
      height: 14px;
      width: 46%;
    }
    .l2 {
      height: 10px;
      width: 72%;
    }
    .st {
      display: grid;
      justify-items: center;
      gap: 10px;
      padding: 56px 16px;
      color: var(--m-ink-muted);
      text-align: center;
      border: 1px dashed var(--m-line);
      border-radius: var(--m-r-lg);
    }
    .ic {
      display: grid;
      place-items: center;
      width: 56px;
      height: 56px;
      border-radius: 50%;
      background: var(--m-accent-soft);
      color: var(--m-accent-ink);
      margin-bottom: 4px;
    }
    .err .ic {
      background: color-mix(in srgb, var(--m-danger) 12%, var(--m-surface));
      color: var(--m-danger);
    }
    strong {
      color: var(--m-ink);
      font-family: var(--m-font-display);
      font-size: 18px;
      font-weight: 600;
    }
    .msg {
      max-width: 48ch;
    }
    button {
      margin-top: 6px;
    }
  `,
})
export class HdState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyKey = input('common.empty');
  readonly icon = input('inbox');
  readonly rows = [0, 1, 2, 3];
  readonly retry = output<void>();
}
