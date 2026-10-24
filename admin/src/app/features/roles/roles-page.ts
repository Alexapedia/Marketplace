import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxChange, MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { RolesApi } from '../../core/api/roles.api';
import { I18nService } from '../../core/i18n/i18n.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { entityId, Role } from '../../core/models/models';
import { AsyncState } from '../../shared/async-state';
import { asList, errMessage, UiService } from '../../shared/ui.service';

export const ALL_PERMISSIONS = [
  'dashboard.read',
  'products.read',
  'products.write',
  'categories.read',
  'categories.write',
  'custom-fields.read',
  'custom-fields.write',
  'orders.read',
  'orders.write',
  'custom-orders.read',
  'custom-orders.write',
  'customers.read',
  'customers.write',
  'chats.read',
  'chats.write',
  'notifications.write',
  'app-config.read',
  'app-config.write',
  'ads.read',
  'ads.write',
  'reports.read',
  'audit-logs.read',
  'roles.read',
  'roles.write',
  'reviews.read',
  'reviews.write',
] as const;

const PERMISSION_GROUPS: { key: string; items: string[] }[] = [
  { key: 'dashboard', items: ['dashboard.read'] },
  {
    key: 'catalog',
    items: [
      'products.read',
      'products.write',
      'categories.read',
      'categories.write',
      'custom-fields.read',
      'custom-fields.write',
    ],
  },
  { key: 'orders', items: ['orders.read', 'orders.write'] },
  { key: 'customOrders', items: ['custom-orders.read', 'custom-orders.write'] },
  { key: 'customers', items: ['customers.read', 'customers.write'] },
  { key: 'chat', items: ['chats.read', 'chats.write'] },
  { key: 'marketing', items: ['ads.read', 'ads.write', 'notifications.write'] },
  { key: 'config', items: ['app-config.read', 'app-config.write'] },
  { key: 'insights', items: ['reports.read', 'audit-logs.read'] },
  { key: 'access', items: ['roles.read', 'roles.write'] },
  { key: 'reviews', items: ['reviews.read', 'reviews.write'] },
];

@Component({
  selector: 'app-roles-page',
  imports: [
    FormsModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
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
  readonly saving = signal(false);
  readonly error = signal<string | null>(null);
  readonly roles = signal<Role[]>([]);
  readonly selectedId = signal('');
  readonly selected = signal<Set<string>>(new Set());
  readonly query = signal('');
  readonly entityId = entityId;
  readonly groups = PERMISSION_GROUPS;
  readonly catalog = ALL_PERMISSIONS;

  readonly selectedRole = computed(() => {
    const id = this.selectedId();
    return this.roles().find((role) => entityId(role) === id) ?? null;
  });

  readonly locked = computed(() => {
    const role = this.selectedRole();
    return !!role && (role.name === 'super_admin' || role.name === 'customer');
  });

  readonly dirty = computed(() => {
    const role = this.selectedRole();
    if (!role || this.locked()) return false;
    const current = [...this.selected()].sort().join('|');
    const saved = [...(role.permissions ?? [])].sort().join('|');
    return current !== saved;
  });

  readonly visibleGroups = computed(() => {
    const q = this.query().trim().toLowerCase();
    return this.groups
      .map((group) => ({
        ...group,
        items: group.items.filter((perm) => {
          if (!q) return true;
          const label = `${this.permLabel(perm)} ${perm} ${this.groupLabel(group.key)}`.toLowerCase();
          return label.includes(q);
        }),
      }))
      .filter((group) => group.items.length > 0);
  });

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list().subscribe({
      next: (res) => {
        const list = asList(res.data).sort((a, b) => this.roleRank(a.name) - this.roleRank(b.name));
        this.roles.set(list);
        const keep = this.selectedId();
        const next =
          list.find((role) => entityId(role) === keep) ??
          list.find((role) => role.name === 'admin') ??
          list[0];
        if (next) this.selectRole(next);
        this.loading.set(false);
      },
      error: (err: unknown) => {
        this.error.set(errMessage(err));
        this.loading.set(false);
      },
    });
  }

  selectRole(role: Role): void {
    this.selectedId.set(entityId(role));
    this.selected.set(new Set(role.permissions ?? []));
    this.query.set('');
  }

  toggle(perm: string, checked: boolean): void {
    if (this.locked()) return;
    const next = new Set(this.selected());
    if (checked) next.add(perm);
    else next.delete(perm);
    this.selected.set(next);
  }

  onCheck(perm: string, event: MatCheckboxChange): void {
    this.toggle(perm, event.checked);
  }

  groupState(items: string[]): 'all' | 'some' | 'none' {
    const count = items.filter((perm) => this.selected().has(perm)).length;
    if (count === 0) return 'none';
    if (count === items.length) return 'all';
    return 'some';
  }

  toggleGroup(items: string[], checked: boolean): void {
    if (this.locked()) return;
    const next = new Set(this.selected());
    for (const perm of items) {
      if (checked) next.add(perm);
      else next.delete(perm);
    }
    this.selected.set(next);
  }

  selectAll(checked: boolean): void {
    if (this.locked()) return;
    this.selected.set(checked ? new Set(ALL_PERMISSIONS) : new Set());
  }

  reset(): void {
    const role = this.selectedRole();
    if (role) this.selected.set(new Set(role.permissions ?? []));
  }

  save(): void {
    const role = this.selectedRole();
    if (!role || this.locked()) return;
    this.saving.set(true);
    this.api.update(entityId(role), { permissions: [...this.selected()] }).subscribe({
      next: (res) => {
        const updated = res.data;
        this.roles.update((list) =>
          list.map((item) => (entityId(item) === entityId(role) ? { ...item, ...updated } : item)),
        );
        this.selected.set(new Set(updated.permissions ?? [...this.selected()]));
        this.saving.set(false);
        this.ui.success(this.i18n.t('roles.saved'));
      },
      error: (err: unknown) => {
        this.saving.set(false);
        this.ui.error(errMessage(err));
      },
    });
  }

  has(perm: string): boolean {
    return this.selected().has(perm);
  }

  count(role: Role): number {
    return (role.permissions ?? []).length;
  }

  roleLabel(name: string): string {
    const key = `roles.names.${name}`;
    const value = this.i18n.t(key);
    return value === key ? name.replaceAll('_', ' ') : value;
  }

  groupLabel(key: string): string {
    return this.i18n.t(`roles.groups.${key}`);
  }

  permLabel(perm: string): string {
    const key = `roles.p.${perm}`;
    const value = this.i18n.t(key);
    if (value !== key) return value;
    const [mod, action] = perm.split('.');
    return `${mod.replaceAll('-', ' ')} · ${action}`;
  }

  lockHint(name: string): string {
    if (name === 'super_admin') return this.i18n.t('roles.lockSuper');
    if (name === 'customer') return this.i18n.t('roles.lockCustomer');
    return '';
  }

  private roleRank(name: string): number {
    const order = [
      'super_admin',
      'admin',
      'order_manager',
      'product_manager',
      'marketing_manager',
      'support_agent',
      'customer',
    ];
    const index = order.indexOf(name);
    return index === -1 ? 80 : index;
  }
}
