import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { User } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class CustomersApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<User[]>> {
    return this.api.get<User[]>('/admin/customers', params);
  }

  get(id: string): Observable<ApiResult<User>> {
    return this.api.get<User>(`/admin/customers/${id}`);
  }

  updateStatus(id: string, status: 'active' | 'blocked'): Observable<ApiResult<User>> {
    return this.api.patch<User>(`/admin/customers/${id}`, { status });
  }
}
