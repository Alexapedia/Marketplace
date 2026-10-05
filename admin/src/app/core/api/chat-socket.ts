import { Injectable, signal } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { Subject } from 'rxjs';
import { AuthService } from '../auth/auth.service';
import { ChatMessage } from '../models/models';

export interface ConversationUpdate {
  conversationId?: string;
  customOrderId?: string;
  lastMessage?: string;
  lastMessageAt?: string;
}

@Injectable({ providedIn: 'root' })
export class ChatSocket {
  private socket?: Socket;
  private pendingJoin = '';
  readonly connected = signal(false);
  readonly incoming = new Subject<ChatMessage>();
  readonly conversationUpdated = new Subject<ConversationUpdate>();

  constructor(private readonly auth: AuthService) {}

  connect(): void {
    const token = this.auth.token();
    if (!token) return;
    if (this.socket?.connected) return;
    if (this.socket) {
      this.socket.auth = { token };
      this.socket.connect();
      return;
    }
    this.socket = io('/chat', {
      path: '/socket.io',
      transports: ['polling', 'websocket'],
      auth: { token },
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 800,
      withCredentials: true,
    });
    this.socket.on('connect', () => {
      this.connected.set(true);
      if (this.pendingJoin) {
        this.socket?.emit('join', { conversationId: this.pendingJoin });
      }
    });
    this.socket.on('disconnect', () => this.connected.set(false));
    this.socket.on('connect_error', () => this.connected.set(false));
    this.socket.on('message', (message: ChatMessage) => this.incoming.next(message));
    this.socket.on('conversation:updated', (payload: ConversationUpdate) =>
      this.conversationUpdated.next(payload),
    );
  }

  join(conversationId: string): void {
    this.pendingJoin = conversationId;
    this.connect();
    if (!conversationId || !this.socket) return;
    if (this.socket.connected) {
      this.socket.emit('join', { conversationId });
    }
  }

  send(conversationId: string, text: string): Promise<boolean> {
    return new Promise((resolve) => {
      if (!this.socket?.connected || !conversationId || !text.trim()) {
        resolve(false);
        return;
      }
      const timer = window.setTimeout(() => resolve(false), 4000);
      this.socket.emit(
        'message',
        { conversationId, text: text.trim() },
        (ack?: { ok?: boolean }) => {
          window.clearTimeout(timer);
          resolve(!!ack?.ok);
        },
      );
    });
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = undefined;
    this.pendingJoin = '';
    this.connected.set(false);
  }
}
