import { Component, input, output } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-auth-eye',
  imports: [TranslatePipe],
  host: { style: 'display: contents' },
  template: `
    <button
      class="auth-eye"
      type="button"
      (click)="toggle.emit()"
      [attr.aria-label]="(masked() ? 'showPassword' : 'hidePassword') | t"
    >
      @if (masked()) {
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M2.5 12s3.6-7 9.5-7 9.5 7 9.5 7-3.6 7-9.5 7-9.5-7-9.5-7Z" />
          <circle cx="12" cy="12" r="3" />
        </svg>
      } @else {
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
          <path d="M3 3l18 18" />
          <path d="M10.6 10.6A3 3 0 0 0 12 15a3 3 0 0 0 3-3" />
          <path d="M6.7 6.8C4.4 8.3 2.5 12 2.5 12s3.6 7 9.5 7c2 0 3.8-.6 5.3-1.5" />
          <path d="M14.1 9.1A3 3 0 0 1 17 12c0 .3 0 .5-.1.8" />
          <path d="M9.9 5.2C10.6 5.1 11.3 5 12 5c5.9 0 9.5 7 9.5 7a16 16 0 0 1-2.2 3.1" />
        </svg>
      }
    </button>
  `,
})
export class AuthEye {
  readonly masked = input.required<boolean>();
  readonly toggle = output<void>();
}
