import { computed, inject, Injectable, signal } from '@angular/core';
import { catchError, map, Observable, of, switchMap, tap } from 'rxjs';
import { AuthApi } from '../api/auth.api';
import { STAFF_ROLES, StaffRole, User } from '../models/models';

const TOKEN_KEY = 'pm_token';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(AuthApi);

  readonly token = signal<string | null>(this.readToken());
  readonly user = signal<User | null>(null);
  readonly ready = signal(false);

  readonly isStaff = computed(() => this.hasStaffRole(this.user()));

  login(email: string, password: string): Observable<User> {
    return this.api.login(email, password).pipe(
      tap((res) => this.persistToken(res.data.accessToken)),
      switchMap(() => this.api.me()),
      tap((res) => this.user.set(res.data)),
      map((res) => res.data),
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
