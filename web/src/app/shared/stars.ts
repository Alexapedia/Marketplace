import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-stars',
  template: `
    <span class="stars" [title]="value.toFixed(1)" role="img" [attr.aria-label]="value.toFixed(1) + ' / 5'">
      @for (s of full; track s) {
        <svg viewBox="0 0 24 24" aria-hidden="true"><path [attr.d]="d" fill="currentColor" /></svg>
      }
      @for (s of empty; track s) {
        <svg class="off" viewBox="0 0 24 24" aria-hidden="true"><path [attr.d]="d" fill="currentColor" /></svg>
      }
      <b aria-hidden="true">{{ value.toFixed(1) }}</b>
    </span>
  `,
})
export class Stars {
  @Input() value = 0;
  readonly d = 'M12 3.2l2.6 5.5 6 .8-4.4 4.1 1.1 5.9L12 16.6l-5.3 2.9 1.1-5.9-4.4-4.1 6-.8L12 3.2Z';

  get full(): number[] {
    const n = Math.round(this.value);
    return Array.from({ length: n }, (_, i) => i);
  }

  get empty(): number[] {
    const n = Math.max(0, 5 - Math.round(this.value));
    return Array.from({ length: n }, (_, i) => i);
  }
}
