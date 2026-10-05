import { ApplicationConfig, APP_INITIALIZER, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { authInterceptor } from './core/auth/auth.interceptor';
import { AuthService } from './core/auth/auth.service';
import { CartService } from './core/cart/cart.service';

function initApp(auth: AuthService, cart: CartService) {
  return () =>
    new Promise<void>((resolve) => {
      auth.restoreSession().subscribe({
        next: (ok) => {
          if (ok) cart.refresh();
          resolve();
        },
        error: () => resolve(),
      });
    });
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    {
      provide: APP_INITIALIZER,
      useFactory: initApp,
      deps: [AuthService, CartService],
      multi: true,
    },
  ],
};
