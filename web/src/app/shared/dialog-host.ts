import { Component, effect, ElementRef, inject, viewChild } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DialogService } from '../core/dialog/dialog.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-dialog-host',
  imports: [FormsModule, TranslatePipe],
  template: `
    @if (dialog.current(); as d) {
      <div class="dlg-backdrop" (click)="dialog.close(null)">
        <div
          class="dlg"
          role="dialog"
          aria-modal="true"
          [attr.aria-label]="d.title | t"
          (click)="$event.stopPropagation()"
          (keydown.escape)="dialog.close(null)"
        >
          <h3>{{ d.title | t }}</h3>
          @if (d.message) {
            <p class="muted">{{ d.message | t }}</p>
          }
          <form (submit)="submit($event)">
            @if (d.inputLabel) {
              <div class="field">
                <label for="dlg-input">{{ d.inputLabel | t }}</label>
                <textarea id="dlg-input" #field name="value" [(ngModel)]="value"></textarea>
              </div>
            }
            <div class="dlg-actions">
              <button class="btn ghost-btn" type="button" (click)="dialog.close(null)">
                {{ 'cancel' | t }}
              </button>
              <button
                #ok
                class="btn"
                [class.danger]="d.danger"
                type="submit"
                [disabled]="d.inputRequired && !value.trim()"
              >
                {{ (d.confirmKey || 'confirm') | t }}
              </button>
            </div>
          </form>
        </div>
      </div>
    }
  `,
})
export class DialogHost {
  readonly dialog = inject(DialogService);
  private readonly field = viewChild<ElementRef<HTMLTextAreaElement>>('field');
  private readonly ok = viewChild<ElementRef<HTMLButtonElement>>('ok');
  value = '';

  constructor() {
    effect(() => {
      if (this.dialog.current()) {
        this.value = '';
        queueMicrotask(() => (this.field() ?? this.ok())?.nativeElement.focus());
      }
    });
  }

  submit(ev: Event): void {
    ev.preventDefault();
    const d = this.dialog.current();
    if (!d) return;
    if (d.inputRequired && !this.value.trim()) return;
    this.dialog.close(d.inputLabel ? this.value.trim() : '');
  }
}
