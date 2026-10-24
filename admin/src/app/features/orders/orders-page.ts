import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { PageEvent } from '@angular/material/paginator';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSelectModule } from '@angular/material/select';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { RouterLink } from '@angular/router';
import { OrdersApi } from '../../core/api/orders.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, loc, Order, ORDER_STATUSES, OrderStatus, PageMeta, productRef } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-reject-dialog',
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ 'orders.rejectionTitle' | t }}</h2>
    <mat-dialog-content [formGroup]="form">
      <p>{{ 'orders.rejectionHint' | t }}</p>
      <mat-form-field appearance="outline" class="full">
        <mat-label>{{ 'orders.rejectionReason' | t }}</mat-label>
        <textarea matInput rows="4" formControlName="reason"></textarea>
      </mat-form-field>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="ok()">{{ 'common.confirm' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `.full{width:100%;min-width:min(420px,80vw)}`,
})
export class RejectDialog {
  private readonly fb = inject(FormBuilder);
  private readonly ref = inject(MatDialogRef<RejectDialog, string>);
  readonly form = this.fb.nonNullable.group({ reason: ['', Validators.required] });

  ok(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.ref.close(this.form.controls.reason.value);
  }
}

@Component({
  selector: 'app-orders-page',
  imports: [
    DatePipe,
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatSelectModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatChipsModule,
    TranslatePipe,
    AsyncState,
    RouterLink,
  ],
  templateUrl: './orders-page.html',
  styleUrl: './orders-page.scss',
})
export class OrdersPage implements OnInit {
  private readonly api = inject(OrdersApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<Order[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly status = signal<string>('');
  readonly search = signal('');
  readonly channel = signal('');
  readonly selected = signal<Order | null>(null);
  readonly statuses = ORDER_STATUSES;
  readonly cols = ['orderNumber', 'customer', 'channel', 'total', 'status', 'createdAt', 'actions'];
  readonly entityId = entityId;
  readonly productRef = productRef;

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({
      page,
      limit,
      status: this.status() || undefined,
      search: this.search() || undefined,
      channel: this.channel() || undefined,
    }).subscribe({
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

  filter(status: string): void {
    this.status.set(status);
    this.load(1);
  }

  onSearch(value: string): void {
    this.search.set(value);
    this.load(1);
  }

  filterChannel(channel: string): void {
    this.channel.set(channel);
    this.load(1);
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  open(order: Order): void {
    this.api.get(entityId(order)).subscribe({
      next: (res) => this.selected.set(res.data),
      error: () => this.selected.set(order),
    });
  }

  customerName(order: Order): string {
    const u = order.userId;
    if (u && typeof u === 'object') {
      return u.name || u.email;
    }
    return order.address?.fullName || String(u ?? '—');
  }

  orderStatus(order: Order): string {
    return order.orderStatus ?? order.status ?? '';
  }

  itemName(name: unknown): string {
    return loc(name as never, this.i18n.lang());
  }

  changeStatus(order: Order, status: OrderStatus): void {
    if (status === 'rejected') {
      this.dialog
        .open(RejectDialog)
        .afterClosed()
        .subscribe((reason: string | undefined) => {
          if (!reason) {
            return;
          }
          this.patchStatus(order, status, reason);
        });
      return;
    }
    this.patchStatus(order, status);
  }

  private patchStatus(order: Order, status: OrderStatus, rejectionReason?: string): void {
    this.api.updateStatus(entityId(order), status, rejectionReason).subscribe({
      next: (res) => {
        this.ui.success(this.i18n.t('common.save'));
        this.selected.set(res.data);
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
