import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AuthChallenge, AuthOk, HolderUser } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class AuthApi {
  private readonly api = inject(ApiClient);

  login(email: string, password: string): Observable<ApiResult<AuthOk | AuthChallenge>> {
    return this.api.post<AuthOk | AuthChallenge>('/platform/auth/login', { email, password });
  }

  verify2fa(challengeToken: string, code: string): Observable<ApiResult<AuthOk>> {
    return this.api.post<AuthOk>('/platform/auth/2fa/verify', { challengeToken, code });
  }

  setup2fa(challengeToken: string, code: string): Observable<ApiResult<AuthOk>> {
    return this.api.post<AuthOk>('/platform/auth/2fa/setup', { challengeToken, code });
  }

  me(): Observable<ApiResult<HolderUser>> {
    return this.api.get<HolderUser>('/platform/auth/me');
  }
}
