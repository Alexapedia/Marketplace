import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { map } from 'rxjs';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isStaff()) {
    return true;
  }

  return auth.restoreSession().pipe(
    map((ok) => (ok && auth.isStaff() ? true : router.createUrlTree(['/login']))),
  );
};

export const guestGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isStaff()) {
    return router.createUrlTree(['/dashboard']);
  }

  if (!auth.token()) {
    return true;
  }

  return auth.restoreSession().pipe(
    map((ok) => (ok && auth.isStaff() ? router.createUrlTree(['/dashboard']) : true)),
  );
};

export const superAdminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  const allow = () => (auth.user()?.role === 'super_admin' ? true : router.createUrlTree(['/dashboard']));

  if (auth.user()) {
    return allow();
  }

  return auth.restoreSession().pipe(map(() => allow()));
};
