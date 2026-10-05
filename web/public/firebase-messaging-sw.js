/* Firebase Cloud Messaging background handler for the customer website. */
importScripts('https://www.gstatic.com/firebasejs/12.19.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.19.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBqSBzBg_VZ2upG8LdGUXSyDV-okMp_4EU',
  authDomain: 'market-place-cfe60.firebaseapp.com',
  projectId: 'market-place-cfe60',
  storageBucket: 'market-place-cfe60.firebasestorage.app',
  messagingSenderId: '113515739998',
  appId: '1:113515739998:web:17dfd75af4807400696dcf',
});

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

try {
  const messaging = firebase.messaging();
  messaging.onBackgroundMessage((payload) => {
    const title = payload.notification?.title || 'Zezo Store';
    const body = payload.notification?.body || '';
    const data = payload.data || {};
    const notify = self.registration.showNotification(title, {
      body,
      data,
      silent: false,
      vibrate: [200, 80, 200],
    });
    const ping = self.clients
      .matchAll({ type: 'window', includeUncontrolled: true })
      .then((clients) => {
        for (const client of clients) {
          client.postMessage({ type: 'PLAY_NOTIFICATION_SOUND' });
        }
      });
    return Promise.all([notify, ping]);
  });
} catch (err) {
  console.warn('FCM SW skipped', err);
}

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  let path = '/notifications';
  if (data.customOrderId) path = `/custom/${data.customOrderId}`;
  else if (data.orderId) path = `/orders/${data.orderId}`;
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      for (const client of clients) {
        if ('focus' in client) {
          client.focus();
          client.navigate(path);
          return;
        }
      }
      return self.clients.openWindow(path);
    }),
  );
});
