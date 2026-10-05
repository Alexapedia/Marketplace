import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { AppNotification, Localized } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class NotificationsApi {
  private readonly api = inject(ApiClient);

  send(body: {
    title: Localized;
    body: Localized;
    target: 'all' | 'userIds';
    userIds?: string[];
  }): Observable<ApiResult<unknown>> {
    return this.api.post<unknown>('/admin/notifications', body);
  }

  history(params?: QueryParams): Observable<ApiResult<AppNotification[]>> {
    return this.api.get<AppNotification[]>('/admin/notifications', params);
  }

  inbox(params?: QueryParams): Observable<ApiResult<AppNotification[]>> {
    return this.api.get<AppNotification[]>('/notifications', params);
  }

  unreadCount(): Observable<ApiResult<{ count: number }>> {
    return this.api.get<{ count: number }>('/notifications/unread-count');
  }

  markRead(id: string): Observable<ApiResult<AppNotification>> {
    return this.api.patch<AppNotification>(`/notifications/${id}/read`);
  }
}
