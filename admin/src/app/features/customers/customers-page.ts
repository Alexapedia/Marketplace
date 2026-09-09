import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { PageEvent } from '@angular/material/paginator';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { CustomersApi } from '../../core/api/customers.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, PageMeta, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-customer-profile-panel',
  imports: [DatePipe, MatDialogModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ 'customers.profile' | t }}</h2>
    <mat-dialog-content>
      <p><strong>{{ data.name }}</strong></p>
      <p>{{ data.email }}</p>
      <p>{{ 'customers.phone' | t }}: {{ data.phone || '—' }}</p>
      <p>{{ 'common.status' | t }}: {{ data.status }}</p>
      <p>{{ 'customers.joined' | t }}: {{ data.createdAt | date: 'medium' }}</p>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.close' | t }}</button>
    </mat-dialog-actions>
  `,
})
export class CustomerProfilePanel {
  readonly data = inject<User>(MAT_DIALOG_DATA);
}

@Component({
  selector: 'app-customers-page',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './customers-page.html',
  styleUrl: './customers-page.scss',
})
export class CustomersPage implements OnInit {
  private readonly api = inject(CustomersApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<User[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly search = signal('');
  readonly cols = ['name', 'email', 'phone', 'status', 'actions'];
  readonly entityId = entityId;

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list({ page, limit, search: this.search() || undefined }).subscribe({
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

  onSearch(value: string): void {
    this.search.set(value);
    this.load(1);
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  profile(user: User): void {
    this.dialog.open(CustomerProfilePanel, { data: user, width: '420px' });
  }

  toggle(user: User): void {
    const next = user.status === 'blocked' ? 'active' : 'blocked';
    this.api.updateStatus(entityId(user), next).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.save'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
