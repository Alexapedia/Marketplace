import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { initializeApp, getApps } from 'firebase/app';
import { getMessaging, getToken, isSupported, onMessage, type Messaging } from 'firebase/messaging';
import { environment } from '../../../environments/environment';
import { AuthApi } from '../api/auth.api';
import { UiService } from '../../shared/ui.service';
import {
  bindNotificationSoundUnlock,
  listenForPushSound,
  playNotificationSound,
} from './notification-sound';

@Injectable({ providedIn: 'root' })
export class FirebasePushService {
  private readonly api = inject(AuthApi);
  private readonly ui = inject(UiService);
  private readonly router = inject(Router);
  private messaging?: Messaging;
  private started = false;

  async start(): Promise<void> {
    const cfg = environment.firebase;
    const token = localStorage.getItem('pm_token');
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
        this.api.updateMe({ fcmToken: fcm }).subscribe({ error: () => undefined });
      }
      onMessage(this.messaging, (payload) => {
        const title = payload.notification?.title || 'Zezo Store';
        const body = payload.notification?.body || '';
        playNotificationSound();
        this.ui.success(body ? `${title}: ${body}` : title);
      });
    } catch (err) {
      console.warn('Firebase web push skipped', err);
      this.started = false;
    }
  }

  routeFrom(data: Record<string, string>): void {
    const type = data['type'] || '';
    if (type === 'new_custom_order') {
      void this.router.navigate(['/custom-orders']);
      return;
    }
    if (type === 'new_order' || data['orderId']) {
      void this.router.navigate(['/orders']);
    }
  }
}
