import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { AuthService } from './auth.service';

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

  return next(authReq).pipe(
    catchError((err: unknown) => {
      if (err instanceof HttpErrorResponse && err.status === 401) {
        const isLogin = req.url.includes('/auth/login');
        if (!isLogin) {
          auth.logout(false);
          void router.navigate(['/login']);
        }
      }
      return throwError(() => err);
    }),
  );
};
