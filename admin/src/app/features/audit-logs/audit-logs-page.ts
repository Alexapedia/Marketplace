import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { AuditLogsApi } from '../../core/api/audit-logs.api';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AuditLog, PageMeta, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage } from '../../shared/ui.service';

@Component({
  selector: 'app-audit-logs-page',
  imports: [DatePipe, MatTableModule, MatPaginatorModule, TranslatePipe, AsyncState],
  template: `
    <h2>{{ 'audit.title' | t }}</h2>
    <app-async-state [loading]="loading()" [error]="error()" [empty]="!loading() && !error() && rows().length === 0" (retry)="load()" />
    @if (!loading() && !error() && rows().length) {
      <table mat-table [dataSource]="rows()" class="full">
        <ng-container matColumnDef="actor">
          <th mat-header-cell *matHeaderCellDef>{{ 'audit.actor' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ actor(row) }}</td>
        </ng-container>
        <ng-container matColumnDef="action">
          <th mat-header-cell *matHeaderCellDef>{{ 'audit.action' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.action }}</td>
        </ng-container>
        <ng-container matColumnDef="entity">
          <th mat-header-cell *matHeaderCellDef>{{ 'audit.entity' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.entity }} {{ row.entityId }}</td>
        </ng-container>
        <ng-container matColumnDef="ip">
          <th mat-header-cell *matHeaderCellDef>{{ 'audit.ip' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.ip }}</td>
        </ng-container>
        <ng-container matColumnDef="createdAt">
          <th mat-header-cell *matHeaderCellDef>{{ 'audit.at' | t }}</th>
          <td mat-cell *matCellDef="let row">{{ row.createdAt | date: 'short' }}</td>
        </ng-container>
        <tr mat-header-row *matHeaderRowDef="cols"></tr>
        <tr mat-row *matRowDef="let row; columns: cols"></tr>
      </table>
      <mat-paginator [length]="meta().total" [pageSize]="meta().limit" [pageIndex]="meta().page - 1" (page)="page($event)" />
    }
  `,
  styles: `.full { width: 100%; }`,
})
export class AuditLogsPage implements OnInit {
  private readonly api = inject(AuditLogsApi);
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<AuditLog[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly cols = ['actor', 'action', 'entity', 'ip', 'createdAt'];

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit }).subscribe({
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

  actor(row: AuditLog): string {
    const a = row.actorId;
    if (a && typeof a === 'object') {
      return (a as User).email || (a as User).name;
    }
    return String(a ?? '—');
  }
}
