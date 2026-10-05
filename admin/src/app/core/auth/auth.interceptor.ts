import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from './auth.service';
import { TelemetryService } from '../telemetry/telemetry.service';

const TOKEN_KEY = 'pm_token';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem(TOKEN_KEY);
  const headers: Record<string, string> = { 'X-Client': 'admin' };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  const authReq = req.clone({ setHeaders: headers });

  const router = inject(Router);
  const auth = inject(AuthService);
  const telemetry = inject(TelemetryService);

  return next(authReq).pipe(
    catchError((err: unknown) => {
      if (err instanceof HttpErrorResponse && err.status === 401) {
        const isLogin =
          req.url.includes('/auth/login') ||
          req.url.includes('/auth/2fa/') ||
          req.url.includes('/auth/register');
        if (!isLogin && !req.url.includes('/telemetry/')) {
          auth.logout(false);
          void router.navigate(['/login']);
        }
      }
      if (
        err instanceof HttpErrorResponse &&
        err.status >= 500 &&
        !req.url.includes('/telemetry/')
      ) {
        telemetry.report('error', err.message || 'HTTP 5xx');
      }
      return throwError(() => err);
    }),
  );
};
