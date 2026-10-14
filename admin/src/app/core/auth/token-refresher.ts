import { HttpBackend, HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { finalize, map, Observable, shareReplay, tap } from 'rxjs';
import { environment } from '../../../environments/environment';

export const TOKEN_KEY = 'pm_token';
export const REFRESH_KEY = 'pm_refresh';

interface RefreshResponse {
  data?: { accessToken: string; refreshToken: string };
}

/** Exchanges the stored refresh token once, sharing the request between concurrent 401s. */
@Injectable({ providedIn: 'root' })
export class TokenRefresher {
  // Raw client: bypasses interceptors so a failed refresh cannot recurse.
  private readonly http = new HttpClient(inject(HttpBackend));
  private inflight?: Observable<string>;

  hasRefreshToken(): boolean {
    return !!localStorage.getItem(REFRESH_KEY);
  }

  refresh(): Observable<string> {
    if (!this.inflight) {
      const refreshToken = localStorage.getItem(REFRESH_KEY) || '';
      this.inflight = this.http
        .post<RefreshResponse>(
          `${environment.apiUrl}/auth/refresh`,
          { refreshToken },
          { headers: { 'X-Client': 'admin' } },
        )
        .pipe(
          map((res) => {
            if (!res.data?.accessToken) throw new Error('Invalid refresh response');
            return res.data;
          }),
          tap((data) => {
            localStorage.setItem(TOKEN_KEY, data.accessToken);
            localStorage.setItem(REFRESH_KEY, data.refreshToken);
          }),
          map((data) => data.accessToken),
          finalize(() => (this.inflight = undefined)),
          shareReplay(1),
        );
    }
    return this.inflight;
  }
}
