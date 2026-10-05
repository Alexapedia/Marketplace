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
      gap: 0;
      overflow-x: auto;
      padding: 16px 8px;
      background: var(--soft);
      border-radius: 16px;
      margin: 16px 0;
    }
    .tl-step {
      display: flex;
      flex-direction: column;
      align-items: center;
      min-width: 64px;
      gap: 8px;
    }
    .tl-dot {
      width: 20px;
      height: 20px;
      border-radius: 50%;
      border: 2px solid var(--line);
      background: transparent;
    }
    .tl-step.done .tl-dot,
    .tl-step.current .tl-dot {
      background: var(--navy);
      border-color: var(--navy);
    }
    .tl-step.current .tl-dot {
      background: var(--gold);
      border-color: var(--gold);
    }
    .tl-step.failed .tl-dot {
      background: #9f1239;
      border-color: #9f1239;
    }
    .tl-label {
      font-size: 11px;
      text-align: center;
      line-height: 1.2;
      max-width: 72px;
    }
    .tl-line {
      flex: 0 0 22px;
      height: 2px;
      background: var(--line);
      margin-top: 10px;
    }
    .tl-line.done {
      background: var(--navy);
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
