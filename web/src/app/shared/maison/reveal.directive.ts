import { Directive, ElementRef, OnDestroy, OnInit, inject, input } from '@angular/core';

const reduceMotion = (): boolean =>
  typeof matchMedia === 'function' && matchMedia('(prefers-reduced-motion: reduce)').matches;

/**
 * Maison entrance: fade + rise + un-blur once the element is 12% visible.
 * `mReveal` is the stagger index (delay = min(index, 7) * 60ms).
 * Without IntersectionObserver or with reduced motion nothing is hidden.
 */
@Directive({ selector: '[mReveal]' })
export class RevealDirective implements OnInit, OnDestroy {
  readonly mReveal = input<number | ''>(0);
  private readonly el = inject(ElementRef<HTMLElement>);
  private observer?: IntersectionObserver;

  ngOnInit(): void {
    const node: HTMLElement = this.el.nativeElement;
    if (typeof IntersectionObserver === 'undefined' || reduceMotion()) return;
    const index = Number(this.mReveal()) || 0;
    node.style.setProperty('--m-delay', `${Math.min(index, 7) * 60}ms`);
    node.classList.add('m-reveal');
    this.observer = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) {
            node.classList.add('is-in');
            this.observer?.disconnect();
          }
        }
      },
      { threshold: 0.12 },
    );
    this.observer.observe(node);
  }

  ngOnDestroy(): void {
    this.observer?.disconnect();
  }
}
