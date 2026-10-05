import { INestApplication } from '@nestjs/common';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { ServerOptions } from 'socket.io';

export class SocketIoAdapter extends IoAdapter {
  constructor(app: INestApplication) {
    super(app.getHttpServer());
  }

  createIOServer(port: number, options?: ServerOptions) {
    return super.createIOServer(port, {
      cors: { origin: true, credentials: true },
      transports: ['websocket', 'polling'],
      allowEIO3: true,
      pingInterval: 25000,
      pingTimeout: 20000,
      ...options,
    });
  }
}
