import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { ChatMessage, Conversation } from '../models/models';
import { ApiClient, ApiResult, QueryParams } from './api-client';

@Injectable({ providedIn: 'root' })
export class ChatsApi {
  private readonly api = inject(ApiClient);

  list(params?: QueryParams): Observable<ApiResult<Conversation[]>> {
    return this.api.get<Conversation[]>('/admin/chats', params);
  }

  messages(id: string): Observable<ApiResult<ChatMessage[]>> {
    return this.api.get<ChatMessage[]>(`/admin/chats/${id}/messages`);
  }

  send(id: string, body: { text?: string; type?: string }): Observable<ApiResult<ChatMessage>> {
    return this.api.post<ChatMessage>(`/admin/chats/${id}/messages`, body);
  }
}
