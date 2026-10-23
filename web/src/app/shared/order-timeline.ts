import { Component, Input, inject } from '@angular/core';
import { I18nService } from '../core/i18n/i18n.service';
import { ORDER_STATUSES } from '../core/models/models';

@Component({
  selector: 'app-order-timeline',
  template: `
    <div class="timeline">
      @for (step of steps; track step; let i = $index; let last = $last) {
        <div
          class="tl-step"
          [class.done]="!failed && idx > i"
          [class.current]="!failed && idx === i"
          [class.failed]="failed && step === status"
        >
          <span class="tl-dot"></span>
          <span class="tl-label">{{ label(step) }}</span>
        </div>
        @if (!last) {
          <div class="tl-line" [class.done]="!failed && idx > i"></div>
        }
      }
    </div>
  `,
  styles: `
    .timeline {
      display: flex;
      align-items: flex-start;
      overflow-x: auto;
      padding: 20px 12px 16px;
      margin: 20px 0;
      border: 1px solid var(--m-line);
      border-radius: var(--m-r-md);
      background: var(--m-surface-2);
      scrollbar-width: none;
    }
    .tl-step {
      display: flex;
      flex-direction: column;
      align-items: center;
      flex: 1 0 72px;
      gap: 10px;
    }
    .tl-dot {
      position: relative;
      width: 14px;
      height: 14px;
      border-radius: 50%;
      border: 1.5px solid color-mix(in srgb, var(--m-ink) 25%, var(--m-line));
      background: var(--m-surface);
      transition: background-color var(--m-dur-base) var(--m-ease-out);
    }
    .tl-step.done .tl-dot {
      background: var(--m-ink);
      border-color: var(--m-ink);
    }
    .tl-step.current .tl-dot {
      background: var(--m-accent);
      border-color: var(--m-accent);
      box-shadow: 0 0 0 5px color-mix(in srgb, var(--m-accent) 22%, transparent);
    }
    .tl-step.current .tl-dot::after {
      content: '';
      position: absolute;
      inset: -6px;
      border-radius: 50%;
      border: 1px solid var(--m-accent);
      animation: tl-pulse 2.4s var(--m-ease-out) infinite;
    }
    .tl-step.failed .tl-dot {
      background: var(--m-danger);
      border-color: var(--m-danger);
    }
    .tl-label {
      font-size: 12px;
      text-align: center;
      line-height: 1.3;
      max-width: 84px;
      color: var(--m-ink-muted);
    }
    .tl-step.done .tl-label,
    .tl-step.current .tl-label {
      color: var(--m-ink);
      font-weight: 600;
    }
    .tl-step.failed .tl-label {
      color: var(--m-danger);
      font-weight: 600;
    }
    .tl-line {
      flex: 1 0 16px;
      height: 1.5px;
      margin-top: 6px;
      background: var(--m-line);
      position: relative;
      overflow: hidden;
    }
    .tl-line.done::after {
      content: '';
      position: absolute;
      inset: 0;
      background: var(--m-ink);
      transform-origin: left center;
      animation: tl-draw var(--m-dur-slow) var(--m-ease-out) both;
    }
    :host-context([dir='rtl']) .tl-line.done::after {
      transform-origin: right center;
    }
    @keyframes tl-draw {
      from { transform: scaleX(0); }
    }
    @keyframes tl-pulse {
      from { transform: scale(0.6); opacity: 1; }
      to { transform: scale(1.6); opacity: 0; }
    }
    @media (prefers-reduced-motion: reduce) {
      .tl-line.done::after,
      .tl-step.current .tl-dot::after {
        animation: none;
      }
      .tl-step.current .tl-dot::after {
        display: none;
      }
    }
  `,
})
export class OrderTimeline {
  @Input({ required: true }) status = 'pending';
  readonly steps = [...ORDER_STATUSES].filter((s) => s !== 'rejected');
  private readonly i18n = inject(I18nService);

  get idx(): number {
    return this.steps.findIndex((step) => step === this.status);
  }

  get failed(): boolean {
    return this.status === 'cancelled' || this.status === 'rejected';
  }

  label(step: string): string {
    return this.i18n.t(`status_${step}`);
  }
}
