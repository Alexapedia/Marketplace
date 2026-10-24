import { Component, inject, Injectable } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { map, Observable } from 'rxjs';
import { TranslatePipe } from '../core/i18n/translate.pipe';

export interface ConfirmData {
  title: string;
  message?: string;
  confirmKey?: string;
  danger?: boolean;
}

@Component({
  selector: 'hd-confirm',
  imports: [MatDialogModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ data.title | t }}</h2>
    @if (data.message) {
      <mat-dialog-content
        ><p>{{ data.message | t }}</p></mat-dialog-content
      >
    }
    <mat-dialog-actions align="end">
      <button mat-button [mat-dialog-close]="false">{{ 'common.cancel' | t }}</button>
      <button
        mat-flat-button
        cdkFocusInitial
        [class.danger]="data.danger"
        [mat-dialog-close]="true"
      >
        {{ data.confirmKey || 'common.confirm' | t }}
      </button>
    </mat-dialog-actions>
  `,
  styles: `
    .danger {
      --mat-button-filled-container-color: var(--m-danger);
      --mat-button-filled-label-text-color: var(--m-surface);
    }
  `,
})
export class ConfirmDialog {
  readonly data = inject<ConfirmData>(MAT_DIALOG_DATA);
}

@Injectable({ providedIn: 'root' })
export class ConfirmService {
  private readonly dialog = inject(MatDialog);

  ask(data: ConfirmData): Observable<boolean> {
    return this.dialog
      .open(ConfirmDialog, { data, width: '420px', maxWidth: '92vw' })
      .afterClosed()
      .pipe(map((v) => v === true));
  }
}
