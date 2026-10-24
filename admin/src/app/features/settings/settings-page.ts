import { Component, computed, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { TranslatePipe } from '../../core/i18n/translate.pipe';
import { AppConfigPage } from '../app-config/app-config-page';
import { CustomFieldsPage } from '../custom-fields/custom-fields-page';
import { RolesPage } from '../roles/roles-page';
import { StaffPage } from '../staff/staff-page';

@Component({
  selector: 'app-settings-page',
  imports: [TranslatePipe, AppConfigPage, StaffPage, RolesPage, CustomFieldsPage],
  templateUrl: './settings-page.html',
  styleUrl: './settings-page.scss',
})
export class SettingsPage {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  readonly auth = inject(AuthService);

  readonly canStaff = computed(() =>
    this.auth.canAccess(['super_admin', 'admin'], ['customers.read', 'customers.write']),
  );
  readonly canRoles = computed(() => this.auth.canAccess(undefined, undefined, true));
  readonly canFields = computed(() =>
    this.auth.canAccess(
      ['super_admin', 'admin', 'product_manager'],
      ['custom-fields.read', 'products.write'],
    ),
  );
  readonly canConfig = computed(() =>
    this.auth.canAccess(['super_admin', 'admin'], ['app-config.read', 'app-config.write']),
  );

  readonly active = signal(this.route.snapshot.queryParamMap.get('tab') || 'support');

  readonly tabs = computed(() => {
    const items: Array<{ key: string; label: string }> = [];
    if (this.canConfig()) {
      items.push({ key: 'support', label: 'settings.support' });
      items.push({ key: 'upgrade', label: 'settings.upgrade' });
    }
    if (this.canStaff()) items.push({ key: 'staff', label: 'settings.staff' });
    if (this.canConfig()) items.push({ key: 'onboarding', label: 'settings.onboarding' });
    if (this.canRoles()) items.push({ key: 'roles', label: 'nav.roles' });
    if (this.canFields()) items.push({ key: 'fields', label: 'nav.customFields' });
    return items;
  });

  readonly configSection = computed(() => {
    const key = this.active();
    if (key === 'upgrade' || key === 'onboarding' || key === 'support') {
      return key;
    }
    return 'support';
  });

  select(key: string): void {
    this.active.set(key);
    void this.router.navigate([], {
      relativeTo: this.route,
      queryParams: { tab: key },
      queryParamsHandling: 'merge',
    });
  }
}
