import { HttpErrorResponse, HttpInterceptorFn, HttpRequest } from '@angular/common/http';
import { inject, Injector } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, switchMap, throwError } from 'rxjs';
import { I18nService } from '../i18n/i18n.service';
import { AuthService } from './auth.service';
import { TOKEN_KEY } from './token';
import { TokenRefresher } from './token-refresher';
import { TelemetryService } from '../telemetry/telemetry.service';

const AUTH_PATHS = ['/auth/login', '/auth/register', '/auth/refresh', '/auth/logout'];

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const i18n = inject(I18nService);
  const injector = inject(Injector);
  const router = inject(Router);
  const refresher = inject(TokenRefresher);
  const telemetry = inject(TelemetryService);

  const withHeaders = (r: HttpRequest<unknown>, token: string | null) => {
    const headers: Record<string, string> = {
      'Accept-Language': i18n.lang(),
      'X-Client': 'website',
    };
    if (token) headers['Authorization'] = `Bearer ${token}`;
    return r.clone({ setHeaders: headers });
  };

  const sendsAuth = !!localStorage.getItem(TOKEN_KEY);
  const isAuthCall = AUTH_PATHS.some((p) => req.url.includes(p));
  const isTelemetry = req.url.includes('/telemetry/');

  const expireSession = () => {
    injector.get(AuthService).logout(false);
    void router.navigate(['/login']);
  };

  return next(withHeaders(req, localStorage.getItem(TOKEN_KEY))).pipe(
    catchError((err: unknown) => {
      if (
        err instanceof HttpErrorResponse &&
        err.status === 401 &&
        sendsAuth &&
        !isAuthCall &&
        !isTelemetry
      ) {
        if (!refresher.hasRefreshToken()) {
          expireSession();
          return throwError(() => err);
        }
        return refresher.refresh().pipe(
          catchError(() => {
            expireSession();
            return throwError(() => err);
          }),
          switchMap((token) => next(withHeaders(req, token))),
        );
      }
      if (err instanceof HttpErrorResponse && err.status >= 500 && !isTelemetry) {
        telemetry.report('error', err.message || 'HTTP 5xx');
      }
      return throwError(() => err);
    }),
  );
};
