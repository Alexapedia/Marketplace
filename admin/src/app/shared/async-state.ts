import { Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-async-state',
  imports: [MatButtonModule, MatIconModule, TranslatePipe],
  template: `
    @if (loading()) {
      <div class="state skeleton" role="status" [attr.aria-label]="'common.loading' | t">
        <div class="sk-head">
          <span class="m-skeleton" style="width: 22%"></span>
          <span class="m-skeleton" style="width: 14%"></span>
          <span class="m-skeleton" style="width: 18%"></span>
        </div>
        @for (row of rows; track row) {
          <div class="sk-row">
            <span class="m-skeleton dot"></span>
            <span class="m-skeleton" [style.width.%]="38 - (row % 3) * 6"></span>
            <span class="m-skeleton" style="width: 16%"></span>
            <span class="m-skeleton pill"></span>
          </div>
        }
        <span class="sr">{{ 'common.loading' | t }}</span>
      </div>
    } @else if (error()) {
      <div class="state message m-enter" role="alert">
        <div class="ring danger"><mat-icon>error_outline</mat-icon></div>
        <p class="msg">{{ error() }}</p>
        <button mat-flat-button (click)="retry.emit()">
          <mat-icon>refresh</mat-icon>{{ 'common.retry' | t }}
        </button>
      </div>
    } @else if (empty()) {
      <div class="state message m-enter">
        <div class="ring"><mat-icon>inbox</mat-icon></div>
        <p class="msg">{{ emptyText() || ('common.empty' | t) }}</p>
      </div>
    }
  `,
  styles: `
    :host { display: block; }
    .state {
      border-radius: var(--m-r-lg);
      background: var(--m-surface);
      border: 1px solid var(--m-line);
      box-shadow: var(--m-shadow-1), var(--m-highlight);
    }
    .skeleton { padding: 8px 0; overflow: hidden; }
    .sk-head, .sk-row {
      display: flex;
      align-items: center;
      gap: 24px;
      padding: 14px 20px;
    }
    .sk-head { border-bottom: 1px solid var(--m-line); }
    .sk-row + .sk-row { border-top: 1px solid var(--m-line); }
    .sk-head span, .sk-row span { display: block; height: 12px; }
    .sk-row span.dot { width: 40px; height: 40px; border-radius: var(--m-r-sm); flex: none; }
    .sk-row span.pill { width: 72px; height: 24px; border-radius: var(--m-r-pill); margin-inline-start: auto; }
    .message {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 14px;
      padding: 56px 24px;
      text-align: center;
    }
    .ring {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      display: grid;
      place-items: center;
      color: var(--m-accent-ink);
      background: var(--m-accent-soft);
      box-shadow: 0 0 0 8px color-mix(in srgb, var(--m-accent) 7%, transparent);
    }
    .ring.danger {
      color: var(--m-danger);
      background: color-mix(in srgb, var(--m-danger) 12%, var(--m-surface));
      box-shadow: 0 0 0 8px color-mix(in srgb, var(--m-danger) 6%, transparent);
    }
    .ring mat-icon { font-size: 30px; width: 30px; height: 30px; }
    .msg {
      margin: 0;
      max-width: 420px;
      color: var(--m-ink-muted);
      font-size: 15px;
    }
    .sr {
      position: absolute;
      width: 1px;
      height: 1px;
      overflow: hidden;
      clip-path: inset(50%);
    }
  `,
})
export class AsyncState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyText = input('');
  readonly retry = output<void>();
  /** Skeleton row indices (visual only). */
  readonly rows = [0, 1, 2, 3, 4, 5];
}
