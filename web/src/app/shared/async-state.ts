import { Component, input, output } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

/**
 * Loading skeleton / error with retry / empty message for list pages.
 * Renders nothing once data is present.
 */
@Component({
  selector: 'app-async-state',
  imports: [TranslatePipe],
  template: `
    @if (loading()) {
      @if (kind() === 'grid') {
        <div class="grid" aria-busy="true">
          @for (i of slots; track i) {
            <div class="sk-card"><div class="sk sk-pic"></div><div class="sk sk-line"></div><div class="sk sk-line short"></div></div>
          }
        </div>
      } @else {
        <div aria-busy="true">
          @for (i of slots.slice(0, 4); track i) {
            <div class="sk sk-row"></div>
          }
        </div>
      }
    } @else if (error()) {
      <div class="state-box" role="alert">
        <p>{{ error() }}</p>
        <button class="btn navy" type="button" (click)="retry.emit()">{{ 'retry' | t }}</button>
      </div>
    } @else if (empty()) {
      <p class="empty">{{ emptyKey() | t }}</p>
    }
  `,
})
export class AsyncState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyKey = input('emptyList');
  readonly kind = input<'grid' | 'list'>('list');
  readonly retry = output<void>();
  readonly slots = [1, 2, 3, 4, 5, 6, 7, 8];
}
