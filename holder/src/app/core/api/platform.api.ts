import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import {
  PlatformAudit,
  PlatformIssue,
  PlatformOverview,
  PlatformReports,
  TenantRow,
} from '../models/models';
import { ApiClient, ApiResult, UploadProgress } from './api-client';

@Injectable({ providedIn: 'root' })
export class PlatformApi {
  private readonly api = inject(ApiClient);

  overview(): Observable<ApiResult<PlatformOverview>> {
    return this.api.get<PlatformOverview>('/platform/overview');
  }

  tenants(): Observable<ApiResult<TenantRow[]>> {
    return this.api.get<TenantRow[]>('/platform/tenants');
  }

  tenant(id: string): Observable<ApiResult<TenantRow>> {
    return this.api.get<TenantRow>(`/platform/tenants/${id}`);
  }

  create(body: unknown): Observable<ApiResult<TenantRow>> {
    return this.api.post<TenantRow>('/platform/tenants', body);
  }

  patch(id: string, body: unknown): Observable<ApiResult<TenantRow>> {
    return this.api.patch<TenantRow>(`/platform/tenants/${id}`, body);
  }

  /** Store logo upload (holder token); resolves to `{ url }`. */
  uploadLogo(file: File): Observable<UploadProgress<{ url: string }>> {
    return this.api.uploadWithProgress<{ url: string }>(file, '/platform/uploads');
  }

  setChannel(
    id: string,
    channel: 'website' | 'admin' | 'mobile',
    enabled: boolean,
  ): Observable<ApiResult<TenantRow>> {
    return this.api.patch<TenantRow>(`/platform/tenants/${id}/channels`, { channel, enabled });
  }

  setStatus(id: string, status: 'active' | 'suspended'): Observable<ApiResult<TenantRow>> {
    return this.api.patch<TenantRow>(`/platform/tenants/${id}/status`, { status });
  }

  reset2fa(id: string, userId: string): Observable<ApiResult<{ reset: boolean }>> {
    return this.api.post<{ reset: boolean }>(`/platform/tenants/${id}/staff/${userId}/reset-2fa`);
  }

  audit(params?: {
    tenantId?: string;
    page?: number;
    limit?: number;
  }): Observable<ApiResult<PlatformAudit[]>> {
    return this.api.get<PlatformAudit[]>('/platform/audit', params);
  }

  reports(): Observable<ApiResult<PlatformReports>> {
    return this.api.get<PlatformReports>('/platform/reports');
  }

  issues(params?: {
    status?: string;
    channel?: string;
    tenantId?: string;
    page?: number;
    limit?: number;
  }): Observable<ApiResult<PlatformIssue[]>> {
    return this.api.get<PlatformIssue[]>('/platform/issues', params);
  }

  resolveIssue(id: string): Observable<ApiResult<{ resolved: boolean }>> {
    return this.api.patch<{ resolved: boolean }>(`/platform/issues/${id}`);
  }
}
