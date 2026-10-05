import { computed, inject, Injectable, Injector, signal } from '@angular/core';
import { catchError, map, Observable, of, switchMap, tap } from 'rxjs';
import { AuthApi } from '../api/auth.api';
import { FirebasePushService } from '../firebase/firebase-push.service';
import { STAFF_ROLES, StaffRole, User } from '../models/models';

const TOKEN_KEY = 'pm_token';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(AuthApi);
  private readonly injector = inject(Injector);

  readonly token = signal<string | null>(this.readToken());
  readonly user = signal<User | null>(null);
  readonly ready = signal(false);

  readonly isStaff = computed(() => this.hasStaffRole(this.user()));

  login(email: string, password: string): Observable<User> {
    return this.api.login(email, password).pipe(
      tap((res) => {
        const token = res.data?.accessToken;
        if (!token) {
          throw new Error('Invalid login response');
        }
        this.persistToken(token);
      }),
      switchMap((res) => {
        if (res.data?.user) {
          this.user.set(res.data.user);
          return of(res.data.user);
        }
        return this.api.me().pipe(
          tap((me) => this.user.set(me.data)),
          map((me) => me.data),
        );
      }),
      tap(() => void this.injector.get(FirebasePushService).start()),
    );
  }

  restoreSession(): Observable<boolean> {
    if (!this.token()) {
      this.ready.set(true);
      return of(false);
    }
    return this.api.me().pipe(
      tap((res) => this.user.set(res.data)),
      map((res) => this.hasStaffRole(res.data)),
      catchError(() => {
        this.clearSession();
        return of(false);
      }),
      tap(() => this.ready.set(true)),
      tap((ok) => {
        if (ok) void this.injector.get(FirebasePushService).start();
      }),
    );
  }

  logout(callApi = true): void {
    if (callApi && this.token()) {
      this.api.logout().subscribe({ error: () => undefined });
    }
    this.clearSession();
  }

  hasPermission(permission: string): boolean {
    const user = this.user();
    if (!user) {
      return false;
    }
    if (user.role === 'super_admin') {
      return true;
    }
    const perms = user.permissions ?? [];
    if (!perms.length) {
      return true;
    }
    return perms.includes(permission) || perms.includes('*');
  }

  canAccess(roles?: StaffRole[], permissions?: string[], superAdminOnly = false): boolean {
    const user = this.user();
    if (!user || !this.hasStaffRole(user)) {
      return false;
    }
    if (user.role === 'super_admin') {
      return true;
    }
    if (superAdminOnly) {
      return false;
    }
    const perms = user.permissions ?? [];
    if (permissions?.length && perms.length) {
      return permissions.some((p) => perms.includes(p) || perms.includes('*'));
    }
    if (roles?.length) {
      return roles.includes(user.role as StaffRole);
    }
    return true;
  }

  private hasStaffRole(user: User | null): boolean {
    return !!user && user.role !== 'customer' && (STAFF_ROLES as string[]).includes(user.role);
  }

  private persistToken(token: string): void {
    localStorage.setItem(TOKEN_KEY, token);
    this.token.set(token);
  }

  private readToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  private clearSession(): void {
    localStorage.removeItem(TOKEN_KEY);
    this.token.set(null);
    this.user.set(null);
    this.ready.set(true);
  }
}
