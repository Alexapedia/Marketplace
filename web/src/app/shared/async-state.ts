import { Component, input, output } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { Icon } from './icon';

/**
 * Loading skeleton / error with retry / empty message for list pages.
 * Renders nothing once data is present.
 */
@Component({
  selector: 'app-async-state',
  imports: [TranslatePipe, Icon],
  template: `
    @if (loading()) {
      @if (kind() === 'grid') {
        <div class="grid" aria-busy="true">
          @for (i of slots; track i) {
            <div class="sk-card">
              <div class="sk sk-pic"></div>
              <div class="sk sk-line"></div>
              <div class="sk sk-line short"></div>
            </div>
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
      <div class="state-box error-state m-enter" role="alert">
        <span class="empty-mark"><m-icon name="close" /></span>
        <p>{{ error() }}</p>
        <button class="btn navy" type="button" (click)="retry.emit()">{{ 'retry' | t }}</button>
      </div>
    } @else if (empty()) {
      <div class="empty m-enter">
        <span class="empty-mark"><m-icon [name]="icon()" /></span>
        <p>{{ emptyKey() | t }}</p>
      </div>
    }
  `,
})
export class AsyncState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyKey = input('emptyList');
  readonly kind = input<'grid' | 'list'>('list');
  /** Presentation only: icon shown in the empty state. */
  readonly icon = input('spark');
  readonly retry = output<void>();
  readonly slots = [1, 2, 3, 4, 5, 6, 7, 8];
}
