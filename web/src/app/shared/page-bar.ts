import { Location } from '@angular/common';
import { Component, Input, inject } from '@angular/core';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { Icon } from './icon';

@Component({
  selector: 'app-page-bar',
  imports: [TranslatePipe, Icon],
  template: `
    <div class="page-bar m-enter">
      <button class="back" type="button" (click)="back()" [attr.aria-label]="'back' | t">
        <m-icon name="back" />
      </button>
      <div class="page-bar-text">
        <h1 class="page-title">{{ title }}</h1>
        <span class="m-rule" aria-hidden="true"></span>
      </div>
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
