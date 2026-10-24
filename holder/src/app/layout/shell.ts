import {
  afterNextRender,
  Component,
  computed,
  DestroyRef,
  effect,
  ElementRef,
  inject,
  signal,
  viewChild,
} from '@angular/core';
import { BreakpointObserver } from '@angular/cdk/layout';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { filter, map } from 'rxjs';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenavModule } from '@angular/material/sidenav';
import { AuthService } from '../core/auth/auth.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { PlatformApi } from '../core/api/platform.api';
import { MAISON } from '../shared/maison';

@Component({
  selector: 'app-shell',
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive,
    MatSidenavModule,
    MatIconModule,
    MatButtonModule,
    TranslatePipe,
    MAISON,
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
  readonly isMobile = toSignal(
    inject(BreakpointObserver)
      .observe('(max-width: 1023.98px)')
      .pipe(map((s) => s.matches)),
    { initialValue: false },
  );

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

  /** Sliding active-item pill (purely visual). */
  readonly pill = signal({ top: 0, h: 0 });
  readonly scrolled = signal(false);
  private readonly navList = viewChild<ElementRef<HTMLElement>>('navList');

  constructor() {
    const measure = () => requestAnimationFrame(() => this.measurePill());
    this.router.events
      .pipe(
        filter((e) => e instanceof NavigationEnd),
        takeUntilDestroyed(),
      )
      .subscribe(() => measure());
    afterNextRender(() => measure());
    effect(() => {
      this.i18n.lang();
      this.issueCount();
      measure();
    });
    const onResize = () => measure();
    window.addEventListener('resize', onResize);
    inject(DestroyRef).onDestroy(() => window.removeEventListener('resize', onResize));
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

  /** Re-position the active pill (e.g. when the mobile drawer opens). */
  remeasure(): void {
    requestAnimationFrame(() => this.measurePill());
  }

  onScroll(event: Event): void {
    this.scrolled.set((event.target as HTMLElement).scrollTop > 8);
  }

  private measurePill(): void {
    const host = this.navList()?.nativeElement;
    const active = host?.querySelector<HTMLElement>('.nav-item.active');
    if (!host || !active) {
      this.pill.set({ top: this.pill().top, h: 0 });
      return;
    }
    this.pill.set({ top: active.offsetTop, h: active.offsetHeight });
  }

  private refreshIssues(): void {
    this.api.issues({ status: 'open', limit: 1 }).subscribe({
      next: (res) => this.issueCount.set(res.meta?.total ?? (res.data || []).length),
      error: () => undefined,
    });
  }
}
