import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthPayload, User } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class AuthApi {
  private readonly api = inject(ApiClient);

  login(email: string, password: string): Observable<ApiResult<AuthPayload>> {
    return this.api.post<AuthPayload>('/auth/login', { email, password });
  }

  verify2fa(challengeToken: string, code: string): Observable<ApiResult<AuthPayload>> {
    return this.api.post<AuthPayload>('/auth/2fa/verify', { challengeToken, code });
  }

  setup2fa(challengeToken: string, code: string): Observable<ApiResult<AuthPayload>> {
    return this.api.post<AuthPayload>('/auth/2fa/setup', { challengeToken, code });
  }

  me(): Observable<ApiResult<User>> {
    return this.api.get<User>('/auth/me');
  }

  updateMe(body: { fcmToken?: string }): Observable<ApiResult<User>> {
    return this.api.patch<User>('/auth/me', body);
  }

  logout(): Observable<ApiResult<unknown>> {
    return this.api.post<unknown>('/auth/logout');
  }
}
