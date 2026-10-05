import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AuthService } from '../core/auth/auth.service';
import { CartService } from '../core/cart/cart.service';
import { I18nService } from '../core/i18n/i18n.service';
import { TranslatePipe } from '../core/i18n/translate.pipe';
import { ThemeService } from '../core/theme/theme.service';

@Component({
  selector: 'app-shell',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, FormsModule, TranslatePipe],
  templateUrl: './shell.html',
  styleUrl: './shell.scss',
})
export class Shell {
  readonly year = new Date().getFullYear();
  readonly auth = inject(AuthService);
  readonly cart = inject(CartService);
  readonly i18n = inject(I18nService);
  readonly theme = inject(ThemeService);
  private readonly router = inject(Router);

  searchQ = '';

  constructor() {
    this.router.events
      .pipe(
        filter((e): e is NavigationEnd => e instanceof NavigationEnd),
        takeUntilDestroyed(),
      )
      .subscribe(() => {
        if (this.router.url.startsWith('/shop')) {
          const q = new URLSearchParams(this.router.url.split('?')[1] || '').get('q') || '';
          this.searchQ = q;
        }
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
