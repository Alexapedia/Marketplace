import { Component, computed, HostListener, inject, OnDestroy, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AuthService } from '../core/auth/auth.service';
import { CartService } from '../core/cart/cart.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';
import { ApiClient } from '../core/api/api-client';
import { StoreConfigService } from '../core/config/store-config.service';
import {
  bindNotificationSoundUnlock,
  listenForPushSound,
  playNotificationSound,
} from '../core/firebase/notification-sound';
import { Icon } from '../shared/icon';
import { BumpDirective } from '../shared/maison';

@Component({
  selector: 'app-shell',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, FormsModule, TranslatePipe, Icon, BumpDirective],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell implements OnDestroy {
  readonly year = new Date().getFullYear();
  readonly auth = inject(AuthService);
  readonly cart = inject(CartService);
  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);
  readonly store = inject(StoreConfigService);
  readonly unread = signal(0);
  private readonly router = inject(Router);
  private readonly api = inject(ApiClient);
  private unreadTimer?: ReturnType<typeof setInterval>;
  private unreadReady = false;

  searchQ = '';

  /** Presentation only: header turns to glass after 8px and sits over the hero on home. */
  readonly scrolled = signal(false);
  readonly onHome = signal(true);
  readonly logoSrc = computed(() => {
    const dark = this.theme.mode() === 'dark' || (this.onHome() && !this.scrolled());
    return (dark && this.store.logoDark()) || this.store.logo();
  });

  @HostListener('window:scroll')
  onScroll(): void {
    const s = window.scrollY > 8;
    if (s !== this.scrolled()) this.scrolled.set(s);
  }

  constructor() {
    bindNotificationSoundUnlock();
    listenForPushSound();
    this.refreshUnread();
    this.unreadTimer = setInterval(() => this.refreshUnread(), 15000);
    this.router.events
      .pipe(
        filter((e): e is NavigationEnd => e instanceof NavigationEnd),
        takeUntilDestroyed(),
      )
      .subscribe(() => {
        this.onHome.set(this.router.url.split(/[?#]/)[0] === '/');
        this.onScroll();
        if (this.router.url.startsWith('/shop')) {
          const q = new URLSearchParams(this.router.url.split('?')[1] || '').get('q') || '';
          this.searchQ = q;
        }
      });
  }

  ngOnDestroy(): void {
    if (this.unreadTimer) clearInterval(this.unreadTimer);
  }

  private refreshUnread(): void {
    if (!this.auth.token()) {
      this.unread.set(0);
      this.unreadReady = false;
      return;
    }
    this.api.get<{ count: number }>('/notifications/unread-count').subscribe({
      next: (res) => {
        const count = Number(res.data?.count ?? 0);
        if (this.unreadReady && count > this.unread()) {
          playNotificationSound();
        }
        this.unread.set(count);
        this.unreadReady = true;
      },
      error: () => undefined,
    });
  }

  onSearch(ev: Event): void {
    ev.preventDefault();
    void this.router.navigate(['/shop'], {
      queryParams: { q: this.searchQ.trim() || null },
    });
  }

  liveSearch(): void {
    void this.router.navigate(['/shop'], {
      queryParams: { q: this.searchQ.trim() || null },
    });
  }

  toggleLang(): void {
    this.i18n.toggle();
  }

  toggleTheme(): void {
    this.theme.toggle();
  }

  logout(): void {
    this.auth.logout();
    void this.router.navigate(['/']);
  }
}
