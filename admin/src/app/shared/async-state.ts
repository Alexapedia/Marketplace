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
        <mat-spinner diameter="36" />
        <p>{{ 'common.loading' | t }}</p>
      </div>
    } @else if (error()) {
      <mat-card appearance="outlined" class="state-card">
        <mat-card-content>
          <mat-icon>error_outline</mat-icon>
          <p>{{ error() }}</p>
          <button mat-flat-button (click)="retry.emit()">{{ 'common.retry' | t }}</button>
        </mat-card-content>
      </mat-card>
    } @else if (empty()) {
      <div class="state muted">
        <div class="empty-icon"><mat-icon>inbox</mat-icon></div>
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
      padding: 56px 16px;
      color: #5c678c;
    }
    .state-card { max-width: 480px; margin: 24px auto; text-align: center; }
    .state-card p { margin: 8px 0 16px; }
    .muted { opacity: 0.9; }
    .empty-icon {
      width: 64px;
      height: 64px;
      border-radius: 20px;
      background: #e8ebf6;
      display: grid;
      place-items: center;
      color: #071345;
    }
    mat-icon { font-size: 28px; width: 28px; height: 28px; }
  `,
})
export class AsyncState {
  readonly loading = input(false);
  readonly error = input<string | null>(null);
  readonly empty = input(false);
  readonly emptyText = input('');
  readonly retry = output<void>();
}
