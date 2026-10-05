import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { initializeApp, getApps } from 'firebase/app';
import { getMessaging, getToken, isSupported, onMessage, type Messaging } from 'firebase/messaging';
import { environment } from '../../../environments/environment';
import { ApiClient } from '../api/api-client';
import { ToastService } from '../toast/toast.service';
import { TOKEN_KEY } from '../auth/token';
import {
  bindNotificationSoundUnlock,
  listenForPushSound,
  playNotificationSound,
} from './notification-sound';

@Injectable({ providedIn: 'root' })
export class FirebasePushService {
  private readonly api = inject(ApiClient);
  private readonly toast = inject(ToastService);
  private readonly router = inject(Router);
  private messaging?: Messaging;
  private started = false;

  async start(): Promise<void> {
    const cfg = environment.firebase;
    const token = localStorage.getItem(TOKEN_KEY);
    if (this.started || !token || !cfg.appId || !cfg.vapidKey) {
      return;
    }
    this.started = true;
    bindNotificationSoundUnlock();
    listenForPushSound();
    try {
      if (!(await isSupported()) || !('Notification' in window) || !('serviceWorker' in navigator)) {
        return;
      }
      const app = getApps().length ? getApps()[0] : initializeApp(cfg);
      this.messaging = getMessaging(app);
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') return;
      const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
      const fcm = await getToken(this.messaging, {
        vapidKey: cfg.vapidKey,
        serviceWorkerRegistration: registration,
      });
      if (fcm) {
        this.api.patch('/auth/me', { fcmToken: fcm }).subscribe({ error: () => undefined });
      }
      onMessage(this.messaging, (payload) => {
        const title = payload.notification?.title || 'Zezo Store';
        const body = payload.notification?.body || '';
        playNotificationSound();
        this.toast.show(body ? `${title}: ${body}` : title, 3200);
      });
    } catch (err) {
      console.warn('Firebase web push skipped', err);
      this.started = false;
    }
  }

  routeFrom(data: Record<string, string>): void {
    const type = data['type'] || '';
    const orderId = data['orderId'] || '';
    const customId = data['customOrderId'] || '';
    if (type.includes('custom') && customId) {
      void this.router.navigate(['/custom', customId]);
      return;
    }
    if (orderId) {
      void this.router.navigate(['/orders', orderId]);
    }
  }
}
