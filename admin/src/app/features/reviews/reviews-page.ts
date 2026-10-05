import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { PageEvent, MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { RouterLink } from '@angular/router';
import { ReviewsApi } from '../../core/api/reviews.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { PageMeta, productRef, Review } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-reviews-page',
  imports: [
    DatePipe,
    MatTableModule,
    MatPaginatorModule,
    MatButtonModule,
    MatIconModule,
    TranslatePipe,
    AsyncState,
    RouterLink,
  ],
  template: `
    <h2 class="page-h">{{ 'reviews.title' | t }}</h2>
    <div class="filters">
      @for (kind of types; track kind) {
        <button mat-stroked-button [class.on]="type() === kind" (click)="setType(kind)">
          {{ ('reviews.' + (kind || 'all')) | t }}
        </button>
      }
    </div>
    <app-async-state
      [loading]="loading()"
      [error]="error()"
      [empty]="!loading() && !error() && rows().length === 0"
      (retry)="load()"
    />
    @if (!loading() && !error() && rows().length) {
      <div class="table-wrap">
        <table mat-table [dataSource]="rows()" class="full">
          <ng-container matColumnDef="user">
            <th mat-header-cell *matHeaderCellDef>{{ 'reviews.user' | t }}</th>
            <td mat-cell *matCellDef="let row">{{ row.userName }}</td>
          </ng-container>
          <ng-container matColumnDef="type">
            <th mat-header-cell *matHeaderCellDef>{{ 'reviews.type' | t }}</th>
            <td mat-cell *matCellDef="let row">
              @if (row.targetType === 'product' && productRef(row.targetId); as pid) {
                <a class="plink" [routerLink]="['/products']" [queryParams]="{ open: pid }">{{ row.targetType }}</a>
              } @else {
                {{ row.targetType }}
              }
            </td>
          </ng-container>
          <ng-container matColumnDef="rating">
            <th mat-header-cell *matHeaderCellDef>{{ 'reviews.rating' | t }}</th>
            <td mat-cell *matCellDef="let row">{{ row.rating }}</td>
          </ng-container>
          <ng-container matColumnDef="comment">
            <th mat-header-cell *matHeaderCellDef>{{ 'reviews.comment' | t }}</th>
            <td mat-cell *matCellDef="let row">{{ row.comment || '—' }}</td>
          </ng-container>
          <ng-container matColumnDef="createdAt">
            <th mat-header-cell *matHeaderCellDef>{{ 'audit.at' | t }}</th>
            <td mat-cell *matCellDef="let row">{{ row.createdAt | date: 'short' }}</td>
          </ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.actions' | t }}</th>
            <td mat-cell *matCellDef="let row">
              <button mat-button (click)="toggle(row)">
                {{ row.hidden ? ('reviews.show' | t) : ('reviews.hide' | t) }}
              </button>
              <button mat-icon-button (click)="remove(row)"><mat-icon>delete</mat-icon></button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
        <mat-paginator
          [length]="meta().total"
          [pageSize]="meta().limit"
          [pageIndex]="meta().page - 1"
          (page)="page($event)"
        />
      </div>
    }
  `,
  styles: `
    .full { width: 100%; }
    .filters { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; }
    .on { background: #c9a45c; color: #12141c; }
    td { max-width: 280px; }
    .plink { color: #071345; font-weight: 700; text-decoration: underline; }
  `,
})
export class ReviewsPage implements OnInit {
  private readonly api = inject(ReviewsApi);
  private readonly ui = inject(UiService);
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<Review[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly type = signal('');
  readonly types = ['', 'product', 'order', 'app', 'website'];
  readonly cols = ['user', 'type', 'rating', 'comment', 'createdAt', 'actions'];
  readonly productRef = productRef;

  ngOnInit(): void {
    this.load();
  }

  setType(value: string): void {
    this.type.set(value);
    this.load(1);
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api
      .list({ page, limit, targetType: this.type() || undefined })
      .subscribe({
        next: (res) => {
          this.rows.set(asList(res.data));
          this.meta.set(res.meta ?? { page, limit, total: asList(res.data).length, totalPages: 1 });
          this.loading.set(false);
        },
        error: (err: unknown) => {
          this.error.set(errMessage(err));
          this.loading.set(false);
        },
      });
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  toggle(row: Review): void {
    const id = row.id || row._id;
    if (!id) return;
    this.api.patch(id, { hidden: !row.hidden }).subscribe({
      next: () => this.load(),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }

  remove(row: Review): void {
    const id = row.id || row._id;
    if (!id) return;
    this.api.remove(id).subscribe({
      next: () => this.load(),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
