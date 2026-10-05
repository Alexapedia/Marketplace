import { Component, computed, inject, OnDestroy, signal } from '@angular/core';
import { Location } from '@angular/common';
import { toSignal } from '@angular/core/rxjs-interop';
import { BreakpointObserver } from '@angular/cdk/layout';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatBadgeModule } from '@angular/material/badge';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatMenuModule } from '@angular/material/menu';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatTooltipModule } from '@angular/material/tooltip';
import { filter, map } from 'rxjs';
import { AuthService } from '../core/auth/auth.service';
import { NotificationsApi } from '../core/api/notifications.api';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { AppNotification, loc, StaffRole } from '../core/models/models';
import { asList } from '../shared/ui.service';
import {
  bindNotificationSoundUnlock,
  listenForPushSound,
  playNotificationSound,
} from '../core/firebase/notification-sound';

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
    MatBadgeModule,
    TranslatePipe,
  ],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell implements OnDestroy {
  private readonly bp = inject(BreakpointObserver);
  private readonly router = inject(Router);
  private readonly location = inject(Location);
  private readonly inboxApi = inject(NotificationsApi);
  readonly auth = inject(AuthService);
  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);
  readonly inbox = signal<AppNotification[]>([]);
  readonly unread = signal(0);
  private inboxTimer?: ReturnType<typeof setInterval>;
  private inboxReady = false;

  readonly isTablet = toSignal(
    this.bp.observe('(max-width: 1024px)').pipe(map((r) => r.matches)),
    { initialValue: false },
  );

  readonly sidenavOpened = signal(true);

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
      icon: 'campaign',
      labelKey: 'nav.notifications',
      roles: ['super_admin', 'admin', 'marketing_manager'],
      permissions: ['notifications.write'],
    },
    {
      path: '/settings',
      icon: 'settings',
      labelKey: 'nav.settings',
      roles: ['super_admin', 'admin', 'product_manager'],
      permissions: ['app-config.write', 'custom-fields.read', 'roles.read', 'customers.write'],
    },
    {
      path: '/ads',
      icon: 'campaign',
      labelKey: 'nav.ads',
      roles: ['super_admin', 'admin', 'marketing_manager'],
      permissions: ['ads.read', 'ads.write'],
    },
    {
      path: '/reviews',
      icon: 'star_rate',
      labelKey: 'nav.reviews',
      roles: ['super_admin', 'admin', 'support_agent', 'order_manager', 'product_manager', 'marketing_manager'],
      permissions: ['reviews.read', 'reviews.write'],
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
  ];

  readonly pageTitle = toSignal(
    this.router.events.pipe(
      filter((e): e is NavigationEnd => e instanceof NavigationEnd),
      map(() => this.titleFromUrl(this.router.url)),
    ),
    { initialValue: this.titleFromUrl(this.router.url) },
  );

  readonly visibleNav = computed(() =>
    this.navItems.filter((item) =>
      this.auth.canAccess(item.roles, item.permissions, item.superAdminOnly),
    ),
  );

  readonly isDashboard = computed(() => {
    this.pageTitle();
    const url = this.router.url.split('?')[0];
    return url === '/dashboard' || url === '/';
  });

  readonly canGoBack = computed(() => {
    this.pageTitle();
    const url = this.router.url.split('?')[0];
    return url !== '/dashboard' && url !== '/login' && url !== '/';
  });

  goBack(): void {
    this.location.back();
  }

  constructor() {
    bindNotificationSoundUnlock();
    listenForPushSound();
    this.bp.observe('(max-width: 1024px)').subscribe((r) => {
      this.sidenavOpened.set(!r.matches);
    });
    this.refreshInbox();
    this.inboxTimer = setInterval(() => this.refreshInbox(), 20000);
  }

  ngOnDestroy(): void {
    if (this.inboxTimer) clearInterval(this.inboxTimer);
  }

  refreshInbox(): void {
    this.inboxApi.inbox({ limit: 8 }).subscribe({
      next: (res) => {
        const items = asList(res.data);
        const nextUnread = items.filter((n) => !n.readAt).length;
        if (this.inboxReady && nextUnread > this.unread()) {
          playNotificationSound();
        }
        this.inbox.set(items);
        this.unread.set(nextUnread);
        this.inboxReady = true;
      },
      error: () => undefined,
    });
  }

  openInboxItem(item: AppNotification): void {
    const id = item._id ?? item.id ?? '';
    if (id) {
      this.inboxApi.markRead(id).subscribe({ next: () => this.refreshInbox() });
    }
    const data = (item as AppNotification & { data?: { orderId?: string } }).data;
    if (item.type === 'new_order' || data?.orderId) {
      void this.router.navigate(['/orders']);
      return;
    }
    if (item.type === 'new_custom_order') {
      void this.router.navigate(['/custom-orders']);
    }
  }

  inboxTitle(item: AppNotification): string {
    return loc(item.title, this.i18n.lang()) || item.type || '';
  }

  inboxBody(item: AppNotification): string {
    return loc(item.body, this.i18n.lang());
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

  initials(): string {
    const name = this.auth.user()?.name?.trim() || 'Zezo';
    const parts = name.split(/\s+/).filter(Boolean);
    return parts
      .slice(0, 2)
      .map((part) => part[0]?.toUpperCase() ?? '')
      .join('');
  }

  private titleFromUrl(url: string): string {
    const path = url.split('?')[0] ?? url;
    const item = this.navItems?.find((n) => path.startsWith(n.path));
    return item?.labelKey ?? 'nav.dashboard';
  }
}
