import { Component, inject, Injectable } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { map, Observable } from 'rxjs';
import { TranslatePipe } from '../core/i18n/translate.pipe';

export interface ConfirmData {
  /** i18n keys (or literal text). */
  title: string;
  message?: string;
  confirmKey?: string;
  danger?: boolean;
  /** Show a text field; the dialog then resolves with its value. */
  inputLabel?: string;
}

@Component({
  selector: 'app-confirm-dialog',
  imports: [MatDialogModule, MatButtonModule, MatFormFieldModule, MatInputModule, FormsModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ data.title | t }}</h2>
    <mat-dialog-content>
      @if (data.message) {
        <p>{{ data.message | t }}</p>
      }
      @if (data.inputLabel) {
        <mat-form-field appearance="outline" class="full">
          <mat-label>{{ data.inputLabel | t }}</mat-label>
          <textarea matInput [(ngModel)]="value" cdkFocusInitial rows="3"></textarea>
        </mat-form-field>
      }
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button [mat-dialog-close]="null">{{ 'common.cancel' | t }}</button>
      <button
        mat-flat-button
        [class.danger-btn]="data.danger"
        [mat-dialog-close]="data.inputLabel ? value.trim() : true"
        [attr.cdkFocusInitial]="data.inputLabel ? null : ''"
      >
        {{ (data.confirmKey || 'common.confirm') | t }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .full { width: 100%; }
    .danger-btn { --mat-button-filled-container-color: var(--m-danger); --mat-button-filled-label-text-color: var(--mat-sys-on-error); }
  `,
})
export class ConfirmDialog {
  readonly data = inject<ConfirmData>(MAT_DIALOG_DATA);
  value = '';
}

@Injectable({ providedIn: 'root' })
export class ConfirmService {
  private readonly dialog = inject(MatDialog);

  /** Emits true only when the user confirms. */
  ask(data: ConfirmData): Observable<boolean> {
    return this.dialog
      .open(ConfirmDialog, { data, width: '420px', maxWidth: '92vw' })
      .afterClosed()
      .pipe(map((v) => v === true));
  }

  /** Emits the entered text, or null when cancelled. */
  prompt(data: ConfirmData & { inputLabel: string }): Observable<string | null> {
    return this.dialog
      .open(ConfirmDialog, { data, width: '440px', maxWidth: '92vw' })
      .afterClosed()
      .pipe(map((v) => (typeof v === 'string' ? v : null)));
  }
}
