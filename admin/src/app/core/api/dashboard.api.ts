import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { DashboardStats } from '../models/models';
import { ApiClient, ApiResult } from './api-client';

@Injectable({ providedIn: 'root' })
export class DashboardApi {
  private readonly api = inject(ApiClient);

  get(): Observable<ApiResult<DashboardStats>> {
    return this.api.get<DashboardStats>('/admin/dashboard');
  }
}
