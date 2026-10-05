import { Location } from '@angular/common';
import { Component, Input, inject } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-page-bar',
  imports: [TranslatePipe],
  template: `
    <div class="page-bar">
      <button class="back" type="button" (click)="back()" [attr.aria-label]="'back' | t">←</button>
      <h1 class="page-title">{{ title }}</h1>
    </div>
  `,
})
export class PageBar {
  @Input({ required: true }) title = '';
  private readonly location = inject(Location);

  back(): void {
    if (window.history.length > 1) {
      this.location.back();
    } else {
      this.location.go('/');
    }
  }
}
