import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AuditLog } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class AuditLogsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<AuditLog[]>> {
    return this.api.get<AuditLog[]>('/admin/audit-logs', params);
  }
}
