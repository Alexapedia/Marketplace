import { Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { TranslatePipe } from '../core/i18n/translate.pipe';

@Component({
  selector: 'app-async-state',
  imports: [MatProgressSpinnerModule, MatButtonModule, MatCardModule, MatIconModule, TranslatePipe],
  template: `
    @if (loading()) {
      <div class="state">
        <mat-spinner diameter="40" />
        <p>{{ 'common.loading' | t }}</p>
      </div>
    } @else if (error()) {
      <mat-card appearance="outlined" class="state-card">
        <mat-card-content>
          <p>{{ error() }}</p>
          <button mat-flat-button (click)="retry.emit()">{{ 'common.retry' | t }}</button>
        </mat-card-content>
      </mat-card>
    } @else if (empty()) {
      <div class="state muted">
        <mat-icon>inbox</mat-icon>
        <p>{{ emptyText() || ('common.empty' | t) }}</p>
      </div>
    }
  `,
  styles: `
    .state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 12px;
      padding: 48px 16px;
      color: var(--mat-sys-on-surface-variant);
    }
    .state-card { max-width: 480px; margin: 24px auto; }
    .muted { opacity: 0.8; }
    mat-icon { font-size: 40px; width: 40px; height: 40px; }
  `,
})
export class AsyncState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyText = input('');
  readonly retry = output<void>();
}
