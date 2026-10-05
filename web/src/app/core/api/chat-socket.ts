import { Injectable } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { Subject } from 'rxjs';
import { AuthService } from '../auth/auth.service';
import { ChatMessage } from '../models/models';

@Injectable({ providedIn: 'root' })
export class ChatSocket {
  private socket?: Socket;
  private joinedId = '';
  readonly incoming = new Subject<ChatMessage>();

  constructor(private readonly auth: AuthService) {}

  connect(customOrderId: string): void {
    const token = this.auth.token();
    if (!token || !customOrderId) return;
    if (this.socket && this.joinedId === customOrderId && this.socket.connected) return;
    this.disconnect();
    this.joinedId = customOrderId;
    this.socket = io('/chat', {
      path: '/socket.io',
      transports: ['polling', 'websocket'],
      auth: { token },
      extraHeaders: { Authorization: `Bearer ${token}` },
      reconnection: true,
      withCredentials: true,
    });
    this.socket.on('connect', () => {
      this.socket?.emit('join', { customOrderId });
    });
    this.socket.on('message', (message: ChatMessage) => this.incoming.next(message));
  }

  send(customOrderId: string, text: string): boolean {
    if (!this.socket?.connected || !text.trim()) return false;
    this.socket.emit('message', { customOrderId, text: text.trim() });
    return true;
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = undefined;
    this.joinedId = '';
  }
}
