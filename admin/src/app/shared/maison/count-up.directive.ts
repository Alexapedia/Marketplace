import { Directive, ElementRef, OnDestroy, effect, inject, input } from '@angular/core';

/**
 * Animates the element's text from the previous value to `mCountUp` over
 * 900ms (expo-out). `mCountUpFormat` formats each frame; reduced motion jumps
 * straight to the final value.
 */
@Directive({ selector: '[mCountUp]' })
export class CountUpDirective implements OnDestroy {
  readonly mCountUp = input.required<number>();
  readonly mCountUpFormat = input<(n: number) => string>((n) => Math.round(n).toLocaleString());
  private readonly el = inject(ElementRef<HTMLElement>);
  private from = 0;
  private frame = 0;

  constructor() {
    effect(() => {
      const to = Number(this.mCountUp()) || 0;
      const format = this.mCountUpFormat();
      cancelAnimationFrame(this.frame);
      const reduce =
        typeof matchMedia === 'function' && matchMedia('(prefers-reduced-motion: reduce)').matches;
      if (reduce || typeof requestAnimationFrame !== 'function') {
        this.render(format(to));
        this.from = to;
        return;
      }
      const start = performance.now();
      const from = this.from;
      const tick = (now: number) => {
        const t = Math.min(1, (now - start) / 900);
        const eased = t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
        this.render(format(from + (to - from) * eased));
        if (t < 1) this.frame = requestAnimationFrame(tick);
        else this.from = to;
      };
      this.frame = requestAnimationFrame(tick);
    });
  }

  private render(text: string): void {
    this.el.nativeElement.textContent = text;
  }

  ngOnDestroy(): void {
    cancelAnimationFrame(this.frame);
  }
}
