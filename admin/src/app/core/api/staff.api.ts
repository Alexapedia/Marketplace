import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { User } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class StaffApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<User[]>> {
    return this.api.get<User[]>('/admin/staff', params);
  }

  create(body: unknown): Observable<ApiResult<User>> {
    return this.api.post<User>('/admin/staff', body);
  }

  patch(id: string, body: unknown): Observable<ApiResult<User>> {
    return this.api.patch<User>(`/admin/staff/${id}`, body);
  }
}
