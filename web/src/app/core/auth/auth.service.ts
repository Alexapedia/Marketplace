import { inject, Injectable, signal } from '@angular/core';
import { catchError, map, Observable, of, switchMap, tap } from 'rxjs';
import { ApiClient } from '../api/api-client';
import { User } from '../models/models';
import { CartService } from '../cart/cart.service';
import { TOKEN_KEY } from './token';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(ApiClient);
  private readonly cart = inject(CartService);

  readonly token = signal<string | null>(this.readToken());
  readonly user = signal<User | null>(null);
  readonly ready = signal(false);

  login(email: string, password: string): Observable<User> {
    return this.api.post<{ user: User; accessToken: string }>('/auth/login', { email, password }).pipe(
      tap((res) => {
        const token = res.data?.accessToken;
        if (!token) throw new Error('Invalid login response');
        this.persistToken(token);
      }),
      switchMap((res) => {
        if (res.data?.user) {
          this.user.set(res.data.user);
          return of(res.data.user);
        }
        return this.me().pipe(
          tap((u) => this.user.set(u)),
          map((u) => u),
        );
      }),
      tap(() => this.cart.refresh()),
    );
  }

  register(payload: {
    name: string;
    email: string;
    password: string;
    phone?: string;
  }): Observable<User> {
    return this.api.post<{ user: User; accessToken: string }>('/auth/register', payload).pipe(
      tap((res) => {
        const token = res.data?.accessToken;
        if (!token) throw new Error('Invalid register response');
        this.persistToken(token);
        this.user.set(res.data.user);
      }),
      map((res) => res.data.user),
      tap(() => this.cart.refresh()),
    );
  }

  forgotPassword(email: string): Observable<void> {
    return this.api.post('/auth/forgot-password', { email }).pipe(map(() => undefined));
  }

  resetPassword(token: string, password: string): Observable<void> {
    return this.api.post('/auth/reset-password', { token, password }).pipe(map(() => undefined));
  }

  me(): Observable<User> {
    return this.api.get<User>('/auth/me').pipe(map((res) => res.data));
  }

  updateMe(body: Partial<User>): Observable<User> {
    return this.api.patch<User>('/auth/me', body).pipe(
      tap((res) => this.user.set(res.data)),
      map((res) => res.data),
    );
  }

  deleteAccount(): Observable<void> {
    return this.api.delete('/auth/me').pipe(
      tap(() => this.clearSession()),
      map(() => undefined),
    );
  }

  restoreSession(): Observable<boolean> {
    if (!this.token()) {
      this.ready.set(true);
      return of(false);
    }
    return this.me().pipe(
      tap((user) => this.user.set(user)),
      map(() => true),
      catchError(() => {
        this.clearSession();
        return of(false);
      }),
      tap(() => this.ready.set(true)),
    );
  }

  logout(callApi = true): void {
    if (callApi && this.token()) {
      this.api.post('/auth/logout').subscribe({ error: () => undefined });
    }
    this.clearSession();
  }

  isLoggedIn(): boolean {
    return !!this.token() && !!this.user();
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
    this.cart.clearLocal();
    this.ready.set(true);
  }
}
