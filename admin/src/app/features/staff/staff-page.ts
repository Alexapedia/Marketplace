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
import { MatTableModule } from '@angular/material/table';
import { MatChipsModule } from '@angular/material/chips';
import { StaffApi } from '../../core/api/staff.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, PageMeta, STAFF_ROLES, StaffRole, User } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-staff-dialog',
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatSelectModule, MatButtonModule, TranslatePipe],
  template: `
    <h2 mat-dialog-title>{{ 'staff.create' | t }}</h2>
    <mat-dialog-content [formGroup]="form" class="dlg">
      <mat-form-field appearance="outline"><mat-label>{{ 'common.name' | t }}</mat-label><input matInput formControlName="name" /></mat-form-field>
      <mat-form-field appearance="outline"><mat-label>Email</mat-label><input matInput formControlName="email" /></mat-form-field>
      <mat-form-field appearance="outline"><mat-label>{{ 'login.password' | t }}</mat-label><input matInput type="password" formControlName="password" /></mat-form-field>
      <mat-form-field appearance="outline"><mat-label>{{ 'customers.phone' | t }}</mat-label><input matInput formControlName="phone" /></mat-form-field>
      <mat-form-field appearance="outline" class="wide">
        <mat-label>{{ 'staff.role' | t }}</mat-label>
        <mat-select formControlName="role">
          @for (r of roles; track r) {
            <mat-option [value]="r">{{ r }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>{{ 'common.cancel' | t }}</button>
      <button mat-flat-button (click)="save()">{{ 'common.save' | t }}</button>
    </mat-dialog-actions>
  `,
  styles: `.dlg{display:grid;grid-template-columns:1fr 1fr;gap:10px;min-width:min(520px,90vw);padding-top:8px}.wide{grid-column:1/-1}`,
})
export class StaffDialog {
  private readonly fb = inject(FormBuilder);
  private readonly ref = inject(MatDialogRef<StaffDialog, unknown>);
  readonly roles = STAFF_ROLES.filter((r) => r !== 'super_admin');
  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    email: ['', Validators.required],
    password: ['', Validators.required],
    phone: [''],
    role: ['admin' as StaffRole, Validators.required],
  });

  save(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.ref.close(this.form.getRawValue());
  }
}

@Component({
  selector: 'app-staff-page',
  imports: [
    MatTableModule,
    MatPaginatorModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
    MatChipsModule,
    TranslatePipe,
    AsyncState,
  ],
  template: `
    <div class="head">
      <p class="hint">{{ 'staff.hint' | t }}</p>
      <button mat-flat-button (click)="open()"><mat-icon>person_add</mat-icon>{{ 'staff.create' | t }}</button>
    </div>
    <div class="filters">
      <mat-form-field appearance="outline">
        <mat-label>{{ 'common.search' | t }}</mat-label>
        <input matInput [value]="search()" (keyup.enter)="onSearch($any($event.target).value)" />
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>{{ 'staff.role' | t }}</mat-label>
        <mat-select [value]="role()" (selectionChange)="filterRole($event.value)">
          <mat-option value="">{{ 'common.all' | t }}</mat-option>
          @for (r of roles; track r) {
            <mat-option [value]="r">{{ r }}</mat-option>
          }
        </mat-select>
      </mat-form-field>
    </div>
    <app-async-state [loading]="loading()" [error]="error()" [empty]="!loading() && !error() && rows().length === 0" (retry)="load()" />
    @if (!loading() && !error() && rows().length) {
      <div class="table-wrap">
        <table mat-table [dataSource]="rows()" class="full">
          <ng-container matColumnDef="name"><th mat-header-cell *matHeaderCellDef>{{ 'common.name' | t }}</th><td mat-cell *matCellDef="let row">{{ row.name }}</td></ng-container>
          <ng-container matColumnDef="email"><th mat-header-cell *matHeaderCellDef>Email</th><td mat-cell *matCellDef="let row">{{ row.email }}</td></ng-container>
          <ng-container matColumnDef="role"><th mat-header-cell *matHeaderCellDef>{{ 'staff.role' | t }}</th><td mat-cell *matCellDef="let row">{{ row.role }}</td></ng-container>
          <ng-container matColumnDef="status"><th mat-header-cell *matHeaderCellDef>{{ 'common.status' | t }}</th><td mat-cell *matCellDef="let row"><mat-chip [class]="'st-' + row.status">{{ row.status }}</mat-chip></td></ng-container>
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef>{{ 'common.actions' | t }}</th>
            <td mat-cell *matCellDef="let row">
              @if (row.role !== 'super_admin') {
                <mat-form-field appearance="outline" class="mini">
                  <mat-select [value]="row.role" (selectionChange)="setRole(row, $event.value)">
                    @for (r of assignable; track r) {
                      <mat-option [value]="r">{{ r }}</mat-option>
                    }
                  </mat-select>
                </mat-form-field>
                <button mat-button (click)="toggle(row)">{{ row.status === 'blocked' ? ('common.unblock' | t) : ('common.block' | t) }}</button>
              }
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
        <mat-paginator [length]="meta().total" [pageSize]="meta().limit" [pageIndex]="meta().page - 1" (page)="page($event)" />
      </div>
    }
  `,
  styles: `
    .head { display:flex; justify-content:space-between; gap:12px; align-items:center; margin-bottom:8px; }
    .hint { margin:0; color:#5c678c; }
    .filters { display:flex; flex-wrap:wrap; gap:12px; }
    .filters mat-form-field { width: min(240px, 100%); }
    .full { width:100%; }
    .mini { width: 170px; }
  `,
})
export class StaffPage implements OnInit {
  private readonly api = inject(StaffApi);
  private readonly dialog = inject(MatDialog);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);
  readonly roles = STAFF_ROLES;
  readonly assignable = STAFF_ROLES.filter((r) => r !== 'super_admin');
  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly rows = signal<User[]>([]);
  readonly meta = signal<PageMeta>({ page: 1, limit: 20, total: 0, totalPages: 0 });
  readonly search = signal('');
  readonly role = signal('');
  readonly cols = ['name', 'email', 'role', 'status', 'actions'];

  ngOnInit(): void {
    this.load();
  }

  load(page = this.meta().page, limit = this.meta().limit): void {
    this.loading.set(true);
    this.error.set(null);
    this.api
      .list({
        page,
        limit,
        search: this.search() || undefined,
        role: this.role() || undefined,
      })
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

  onSearch(value: string): void {
    this.search.set(value);
    this.load(1);
  }

  filterRole(role: string): void {
    this.role.set(role);
    this.load(1);
  }

  page(ev: PageEvent): void {
    this.load(ev.pageIndex + 1, ev.pageSize);
  }

  open(): void {
    this.dialog
      .open(StaffDialog, { width: '560px' })
      .afterClosed()
      .subscribe((body) => {
        if (!body) return;
        this.api.create(body).subscribe({
          next: () => {
            this.ui.success(this.i18n.t('common.save'));
            this.load();
          },
          error: (err: unknown) => this.ui.error(errMessage(err)),
        });
      });
  }

  setRole(user: User, role: string): void {
    this.api.patch(entityId(user), { role }).subscribe({
      next: () => this.load(),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }

  toggle(user: User): void {
    const status = user.status === 'blocked' ? 'active' : 'blocked';
    this.api.patch(entityId(user), { status }).subscribe({
      next: () => this.load(),
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
