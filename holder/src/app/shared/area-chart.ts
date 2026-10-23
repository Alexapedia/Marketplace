import { Component, computed, inject, input } from '@angular/core';
import { areaPath } from '../core/chart';
import { I18nService } from '../core/i18n/i18n.service';

let uid = 0;

/** Presentational area chart: hairline grid, gradient area and line that grow from the baseline. */
@Component({
  selector: 'hd-area-chart',
  template: `
    <div class="wrap" [class]="'wrap tone-' + tone()" [style.height.px]="height()">
      <svg
        class="hd-chart"
        [attr.viewBox]="'0 0 ' + path().w + ' ' + path().h"
        preserveAspectRatio="none"
        role="img"
        [attr.aria-label]="label()"
      >
        <defs>
          <linearGradient [attr.id]="gid" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" class="s0" />
            <stop offset="100%" class="s1" />
          </linearGradient>
        </defs>
        @for (y of grid; track y) {
          <line class="grid-line" x1="0" [attr.x2]="path().w" [attr.y1]="y * path().h" [attr.y2]="y * path().h" />
        }
        @if (path().line) {
          <path class="area" [attr.d]="path().area" [attr.fill]="'url(#' + gid + ')'" />
          <path class="line" [attr.d]="path().line" fill="none" stroke-width="2" stroke-linejoin="round" stroke-linecap="round" />
        }
      </svg>
    </div>
    @if (days().length) {
      <div class="days" aria-hidden="true">
        @for (d of days(); track $index) {
          <span>{{ d }}</span>
        }
      </div>
    }
  `,
  styles: `
    :host {
      display: block;
    }
    .wrap {
      --tone: var(--m-accent);
      position: relative;
    }
    .wrap.tone-primary {
      --tone: var(--m-primary);
    }
    :host-context(body.dark-theme) .wrap.tone-primary {
      --tone: color-mix(in srgb, var(--m-primary) 30%, var(--m-ink));
    }
    .wrap.tone-danger {
      --tone: var(--m-danger);
    }
    svg {
      height: 100%;
    }
    .s0 {
      stop-color: var(--tone);
      stop-opacity: 0.32;
    }
    .s1 {
      stop-color: var(--tone);
      stop-opacity: 0;
    }
    .line {
      stroke: var(--tone);
    }
    .days {
      display: flex;
      justify-content: space-between;
      gap: 6px;
      overflow: hidden;
      white-space: nowrap;
      margin-top: 10px;
      color: var(--m-ink-muted);
      font-size: 11px;
      font-variant-numeric: tabular-nums;
    }
    @media (max-width: 599.98px) {
      .days span:nth-child(even):not(:last-child) {
        display: none;
      }
    }
  `,
})
export class HdAreaChart {
  private readonly i18n = inject(I18nService);
  readonly values = input<number[]>([]);
  readonly dates = input<string[]>([]);
  readonly tone = input<'accent' | 'primary' | 'danger'>('accent');
  readonly height = input(140);
  readonly label = input('');
  readonly gid = `hd-area-${++uid}`;
  readonly grid = [0.25, 0.5, 0.75, 1];

  readonly path = computed(() => areaPath(this.values(), 640, 120));

  /** Short weekday/day labels; thinned so at most 7 show. */
  readonly days = computed(() => {
    const dates = this.dates();
    const lang = this.i18n.lang();
    const step = Math.ceil(dates.length / 7) || 1;
    return dates
      .filter((_, i) => i % step === 0 || i === dates.length - 1)
      .map((d) => {
        const date = new Date(d + 'T00:00:00');
        if (isNaN(date.getTime())) return d;
        return dates.length > 7
          ? date.toLocaleDateString(lang, { day: 'numeric', month: 'short' })
          : date.toLocaleDateString(lang, { weekday: 'short' });
      });
  });
}
