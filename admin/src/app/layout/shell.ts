import { Component, computed, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { BreakpointObserver } from '@angular/cdk/layout';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { filter, map } from 'rxjs';
import { AuthService } from '../core/auth/auth.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { StaffRole } from '../core/models/models';

interface NavItem {
  path: string;
  icon: string;
  labelKey: string;
  roles?: StaffRole[];
  permissions?: string[];
  superAdminOnly?: boolean;
}

@Component({
  selector: 'app-shell',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatToolbarModule,
    MatIconModule,
    MatButtonModule,
    MatListModule,
    MatMenuModule,
    MatTooltipModule,
    TranslatePipe,
  ],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell {
  private readonly bp = inject(BreakpointObserver);
  private readonly router = inject(Router);
  readonly auth = inject(AuthService);
  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);

  readonly isTablet = toSignal(
    this.bp.observe('(max-width: 1024px)').pipe(map((r) => r.matches)),
    { initialValue: false },
  );

  readonly sidenavOpened = signal(true);

  readonly pageTitle = toSignal(
    this.router.events.pipe(
      filter((e): e is NavigationEnd => e instanceof NavigationEnd),
      map(() => this.titleFromUrl(this.router.url)),
    ),
    { initialValue: this.titleFromUrl(this.router.url) },
  );

  readonly navItems: NavItem[] = [
    { path: '/dashboard', icon: 'dashboard', labelKey: 'nav.dashboard' },
    {
      path: '/products',
      icon: 'inventory_2',
      labelKey: 'nav.products',
      roles: ['super_admin', 'admin', 'product_manager'],
      permissions: ['products.read', 'products.write'],
    },
    {
      path: '/categories',
      icon: 'category',
      labelKey: 'nav.categories',
      roles: ['super_admin', 'admin', 'product_manager'],
      permissions: ['categories.read', 'products.write'],
    },
    {
      path: '/custom-fields',
      icon: 'tune',
      labelKey: 'nav.customFields',
      roles: ['super_admin', 'admin', 'product_manager'],
      permissions: ['custom-fields.read', 'products.write'],
    },
    {
      path: '/orders',
      icon: 'receipt_long',
      labelKey: 'nav.orders',
      roles: ['super_admin', 'admin', 'order_manager', 'support_agent'],
      permissions: ['orders.read', 'orders.write'],
    },
    {
      path: '/custom-orders',
      icon: 'design_services',
      labelKey: 'nav.customOrders',
      roles: ['super_admin', 'admin', 'order_manager', 'support_agent'],
      permissions: ['custom-orders.read', 'orders.write'],
    },
    {
      path: '/customers',
      icon: 'group',
      labelKey: 'nav.customers',
      roles: ['super_admin', 'admin', 'support_agent'],
      permissions: ['customers.read'],
    },
    {
      path: '/chat',
      icon: 'chat',
      labelKey: 'nav.chat',
      roles: ['super_admin', 'admin', 'support_agent'],
      permissions: ['chats.read', 'chats.write'],
    },
    {
      path: '/notifications',
      icon: 'notifications',
      labelKey: 'nav.notifications',
      roles: ['super_admin', 'admin', 'marketing_manager'],
      permissions: ['notifications.write'],
    },
    {
      path: '/app-config',
      icon: 'phonelink_setup',
      labelKey: 'nav.appConfig',
      roles: ['super_admin', 'admin'],
      permissions: ['app-config.write'],
    },
    {
      path: '/reports',
      icon: 'insights',
      labelKey: 'nav.reports',
      roles: ['super_admin', 'admin', 'order_manager'],
      permissions: ['reports.read'],
    },
    {
      path: '/audit-logs',
      icon: 'policy',
      labelKey: 'nav.auditLogs',
      roles: ['super_admin', 'admin'],
      permissions: ['audit-logs.read'],
    },
    {
      path: '/roles',
      icon: 'admin_panel_settings',
      labelKey: 'nav.roles',
      superAdminOnly: true,
    },
  ];

  readonly visibleNav = computed(() =>
    this.navItems.filter((item) =>
      this.auth.canAccess(item.roles, item.permissions, item.superAdminOnly),
    ),
  );

  constructor() {
    this.bp.observe('(max-width: 1024px)').subscribe((r) => {
      this.sidenavOpened.set(!r.matches);
    });
  }

  sidenavMode(): 'over' | 'side' {
    return this.isTablet() ? 'over' : 'side';
  }

  toggleNav(): void {
    this.sidenavOpened.update((v) => !v);
  }

  closeIfOverlay(): void {
    if (this.isTablet()) {
      this.sidenavOpened.set(false);
    }
  }

  logout(): void {
    this.auth.logout();
    void this.router.navigate(['/login']);
  }

  private titleFromUrl(url: string): string {
    const path = url.split('?')[0] ?? url;
    const item = this.navItems.find((n) => path.startsWith(n.path));
    return item?.labelKey ?? 'nav.dashboard';
  }
}
