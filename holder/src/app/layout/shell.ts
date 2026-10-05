import { Component, computed, DestroyRef, inject, signal } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatBadgeModule } from '@angular/material/badge';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { AuthService } from '../core/auth/auth.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { PlatformApi } from '../core/api/platform.api';

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
    MatBadgeModule,
    TranslatePipe,
  ],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell {
  readonly auth = inject(AuthService);
  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);
  private readonly router = inject(Router);
  private readonly api = inject(PlatformApi);

  readonly issueCount = signal(0);

  readonly groups = [
    {
      labelKey: 'nav.control',
      items: [
        { path: '/overview', icon: 'space_dashboard', labelKey: 'nav.overview' },
        { path: '/tenants', icon: 'storefront', labelKey: 'nav.tenants' },
      ],
    },
    {
      labelKey: 'nav.insights',
      items: [
        { path: '/reports', icon: 'monitoring', labelKey: 'nav.reports' },
        { path: '/issues', icon: 'bug_report', labelKey: 'nav.issues', badge: true },
        { path: '/audit', icon: 'policy', labelKey: 'nav.audit' },
      ],
    },
  ];

  constructor() {
    this.refreshIssues();
    const timer = setInterval(() => this.refreshIssues(), 30000);
    inject(DestroyRef).onDestroy(() => clearInterval(timer));
  }

  logout(): void {
    this.auth.logout();
    void this.router.navigate(['/login']);
  }

  readonly initials = computed(() => {
    const name = this.auth.user()?.name || 'H';
    return name
      .split(' ')
      .map((p) => p[0])
      .join('')
      .slice(0, 2)
      .toUpperCase();
  });

  private refreshIssues(): void {
    this.api.issues({ status: 'open' }).subscribe({
      next: (res) => this.issueCount.set((res.data || []).length),
      error: () => undefined,
    });
  }
}
