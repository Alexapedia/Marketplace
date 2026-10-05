import { Injectable } from '@nestjs/common';
import { Server } from 'socket.io';
import { TenantContext } from '../tenant/tenant.context';

export type ChatMessagePayload = {
  _id: string;
  id: string;
  conversationId: string;
  senderId: string;
  senderRole: string;
  type: string;
  text: string;
  attachments: string[];
  createdAt?: Date;
};

@Injectable()
export class ChatRealtimeService {
  private server?: Server;

  attach(server: Server) {
    this.server = server;
  }

  emitMessage(payload: {
    conversationId: string;
    customOrderId?: string;
    message: ChatMessagePayload;
  }) {
    if (!this.server) return;
    const tenantId = TenantContext.tenantId();
    this.server
      .to(`conversation:${payload.conversationId}`)
      .emit('message', payload.message);
    if (tenantId) {
      this.server.to(`staff:${tenantId}`).emit('conversation:updated', {
        conversationId: payload.conversationId,
        customOrderId: payload.customOrderId,
        lastMessage: payload.message.text,
        lastMessageAt: payload.message.createdAt,
      });
    }
  }
}
