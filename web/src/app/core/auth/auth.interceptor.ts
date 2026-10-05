import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject, Injector } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { I18nService } from '../i18n/i18n.service';
import { AuthService } from './auth.service';
import { TOKEN_KEY } from './token';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = localStorage.getItem(TOKEN_KEY);
  const i18n = inject(I18nService);
  const injector = inject(Injector);
  const router = inject(Router);
  const headers: Record<string, string> = {
    'Accept-Language': i18n.lang(),
    'X-Client': 'website',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  const authReq = req.clone({ setHeaders: headers });

  return next(authReq).pipe(
    catchError((err: unknown) => {
      if (err instanceof HttpErrorResponse && err.status === 401) {
        const isAuth = req.url.includes('/auth/login') || req.url.includes('/auth/register');
        if (!isAuth) {
          injector.get(AuthService).logout(false);
          void router.navigate(['/login']);
        }
      }
      return throwError(() => err);
    }),
  );
};
