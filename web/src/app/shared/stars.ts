import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-stars',
  template: `
    <span class="stars" [title]="value.toFixed(1)">
      @for (s of full; track s) {
        ★
      }
      @for (s of empty; track s) {
        ☆
      }
      <b>{{ value.toFixed(1) }}</b>
    </span>
  `,
})
export class Stars {
  @Input() value = 0;

  get full(): number[] {
    const n = Math.round(this.value);
    return Array.from({ length: n }, (_, i) => i);
  }

  get empty(): number[] {
    const n = Math.max(0, 5 - Math.round(this.value));
    return Array.from({ length: n }, (_, i) => i);
  }
}
