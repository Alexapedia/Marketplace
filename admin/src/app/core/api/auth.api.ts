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

  me(): Observable<ApiResult<User>> {
    return this.api.get<User>('/auth/me');
  }

  logout(): Observable<ApiResult<unknown>> {
    return this.api.post<unknown>('/auth/logout');
  }
}
