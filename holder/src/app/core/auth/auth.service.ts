import { Injectable, inject, signal } from '@angular/core';
import { Observable, catchError, map, of, tap } from 'rxjs';
import { AuthApi } from '../api/auth.api';
import { AuthChallenge, AuthOk, HolderUser } from '../models/models';

export const TOKEN_KEY = 'pm_holder_token';

export type LoginOutcome =
  | { kind: 'ok'; user: HolderUser; backupCodes?: string[] }
  | { kind: '2fa'; challengeToken: string }
  | { kind: 'setup'; challengeToken: string; qr?: string; otpauthUrl?: string };

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(AuthApi);

  readonly token = signal<string | null>(this.readToken());
  readonly user = signal<HolderUser | null>(null);
  readonly ready = signal(false);

  login(email: string, password: string): Observable<LoginOutcome> {
    return this.api.login(email, password).pipe(map((res) => this.toOutcome(res.data)));
  }

  verify2fa(challengeToken: string, code: string): Observable<LoginOutcome> {
    return this.api.verify2fa(challengeToken, code).pipe(map((res) => this.toOutcome(res.data)));
  }

  setup2fa(challengeToken: string, code: string): Observable<LoginOutcome> {
    return this.api.setup2fa(challengeToken, code).pipe(map((res) => this.toOutcome(res.data)));
  }

  restoreSession(): Observable<boolean> {
    if (!this.token()) {
      this.ready.set(true);
      return of(false);
    }
    return this.api.me().pipe(
      tap((res) => this.user.set(res.data)),
      map(() => true),
      catchError(() => {
        this.logout();
        return of(false);
      }),
      tap(() => this.ready.set(true)),
    );
  }

  logout(): void {
    localStorage.removeItem(TOKEN_KEY);
    this.token.set(null);
    this.user.set(null);
    this.ready.set(true);
  }

  private toOutcome(data: AuthOk | AuthChallenge): LoginOutcome {
    if ('accessToken' in data && data.accessToken) {
      this.persistToken(data.accessToken);
      this.user.set(data.user);
      return { kind: 'ok', user: data.user, backupCodes: data.backupCodes };
    }
    const challenge = data as AuthChallenge;
    if (challenge.requires2faSetup) {
      return {
        kind: 'setup',
        challengeToken: challenge.challengeToken,
        qr: challenge.qr,
        otpauthUrl: challenge.otpauthUrl,
      };
    }
    return { kind: '2fa', challengeToken: challenge.challengeToken };
  }

  private persistToken(token: string): void {
    localStorage.setItem(TOKEN_KEY, token);
    this.token.set(token);
  }

  private readToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }
}
