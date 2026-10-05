import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';

export type FcmPayload = {
  title: string;
  body: string;
  data?: Record<string, string>;
  clickPath?: string;
};

@Injectable()
export class FirebaseAdminService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseAdminService.name);
  private ready = false;

  constructor(private readonly config: ConfigService) {}

  async onModuleInit() {
    await this.init();
  }

  get enabled() {
    return this.ready;
  }

  async init() {
    if (this.ready) return;
    if (this.config.get<string>('FIREBASE_ENABLED') !== 'true') return;
    try {
      const { cert, getApps, initializeApp } = await import('firebase-admin/app');
      if (!getApps().length) {
        initializeApp({ credential: cert(this.credential()) });
      }
      this.ready = true;
      this.logger.log('Firebase Admin ready');
    } catch (err) {
      this.ready = false;
      this.logger.error(`Firebase Admin init failed: ${(err as Error).message}`);
    }
  }

  async verifyIdToken(idToken: string) {
    await this.init();
    if (!this.ready) {
      throw new Error('Firebase is disabled');
    }
    const { getAuth } = await import('firebase-admin/auth');
    return getAuth().verifyIdToken(idToken);
  }

  async sendToTokens(tokens: string[], payload: FcmPayload) {
    await this.init();
    if (!this.ready || !tokens.length) return [];
    const unique = [...new Set(tokens.filter(Boolean))];
    const { getMessaging } = await import('firebase-admin/messaging');
    const data = this.stringifyData(payload.data);
    const clickPath = payload.clickPath || data['clickPath'] || '/';
    const response = await getMessaging().sendEachForMulticast({
      tokens: unique,
      notification: {
        title: payload.title,
        body: payload.body,
      },
      data,
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'orders',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
      webpush: {
        headers: { Urgency: 'high' },
        notification: {
          title: payload.title,
          body: payload.body,
          silent: false,
          vibrate: [200, 80, 200],
        },
        fcmOptions: { link: clickPath },
      },
    });
    const invalid: string[] = [];
    response.responses.forEach((item, index) => {
      if (item.success) return;
      const code = item.error?.code || '';
      if (
        code.includes('registration-token-not-registered') ||
        code.includes('invalid-registration-token')
      ) {
        invalid.push(unique[index]);
      } else {
        this.logger.warn(`FCM failed: ${item.error?.message}`);
      }
    });
    return invalid;
  }

  private credential() {
    const file = this.config.get<string>('FIREBASE_CREDENTIALS_PATH');
    if (file) {
      const abs = resolve(process.cwd(), file);
      if (existsSync(abs)) {
        return JSON.parse(readFileSync(abs, 'utf8')) as Record<string, string>;
      }
    }
    return {
      projectId: this.config.get<string>('FIREBASE_PROJECT_ID'),
      clientEmail: this.config.get<string>('FIREBASE_CLIENT_EMAIL'),
      privateKey: this.config
        .get<string>('FIREBASE_PRIVATE_KEY')
        ?.replace(/\\n/g, '\n'),
    };
  }

  private stringifyData(data?: Record<string, string>) {
    const out: Record<string, string> = {};
    for (const [key, value] of Object.entries(data ?? {})) {
      if (value == null) continue;
      out[key] = String(value);
    }
    return out;
  }
}
