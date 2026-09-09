import { Component, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { RolesApi } from '../../core/api/roles.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, Role } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

@Component({
  selector: 'app-roles-page',
  imports: [
    FormsModule,
    MatCardModule,
    MatChipsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    TranslatePipe,
    AsyncState,
  ],
  templateUrl: './roles-page.html',
  styleUrl: './roles-page.scss',
})
export class RolesPage implements OnInit {
  private readonly api = inject(RolesApi);
  private readonly ui = inject(UiService);
  readonly i18n = inject(I18nService);

  readonly loading = signal(true);
  readonly error = signal<string | null>(null);
  readonly roles = signal<Role[]>([]);
  readonly drafts = signal<Record<string, string>>({});
  readonly entityId = entityId;

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list().subscribe({
      next: (res) => {
        const list = asList(res.data);
        this.roles.set(list);
        const drafts: Record<string, string> = {};
        for (const role of list) {
          drafts[entityId(role)] = (role.permissions ?? []).join(', ');
        }
        this.drafts.set(drafts);
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  setDraft(id: string, value: string): void {
    this.drafts.update((d) => ({ ...d, [id]: value }));
  }

  save(role: Role): void {
    const id = entityId(role);
    const permissions = (this.drafts()[id] ?? '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean);
    this.api.update(id, { permissions }).subscribe({
      next: () => {
        this.ui.success(this.i18n.t('common.save'));
        this.load();
      },
      error: (err: unknown) => this.ui.error(errMessage(err)),
    });
  }
}
