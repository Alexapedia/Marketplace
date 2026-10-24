import { Directive, ElementRef, effect, inject, input } from '@angular/core';

/** Replays the spring "bump" whenever the bound value changes (e.g. a badge count). */
@Directive({ selector: '[mBump]' })
export class BumpDirective {
  readonly mBump = input<unknown>();
  private readonly el = inject(ElementRef<HTMLElement>);
  private first = true;

  constructor() {
    effect(() => {
      this.mBump();
      if (this.first) {
        this.first = false;
        return;
      }
      const node: HTMLElement = this.el.nativeElement;
      node.classList.remove('m-bump');
      void node.offsetWidth; // restart the animation
      node.classList.add('m-bump');
    });
  }
}
