import { Injectable } from '@nestjs/common';
import { Server } from 'socket.io';

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
    this.server
      .to(`conversation:${payload.conversationId}`)
      .emit('message', payload.message);
    this.server.to('staff').emit('conversation:updated', {
      conversationId: payload.conversationId,
      customOrderId: payload.customOrderId,
      lastMessage: payload.message.text,
      lastMessageAt: payload.message.createdAt,
    });
  }
}
