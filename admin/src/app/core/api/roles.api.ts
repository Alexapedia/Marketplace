import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { Role } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class RolesApi {
  private readonly api = inject(ApiClient);

  list(): Observable<ApiResult<Role[]>> {
    return this.api.get<Role[]>('/admin/roles');
  }

  update(id: string, body: unknown): Observable<ApiResult<Role>> {
    return this.api.patch<Role>(`/admin/roles/${id}`, body);
  }
}
