# Firebase setup

PlaceMarket uses Firebase for Crashlytics, FCM push, and optional Google/Apple login.

## 1. Mobile apps (already added)

- Android: `mobile/android/app/google-services.json`
- iOS: `mobile/ios/Runner/GoogleService-Info.plist`
- FlutterFire options: `mobile/lib/firebase_options.dart`

Enable in Firebase Console:

1. Authentication: Email/Password, Google, Apple.
2. Cloud Messaging.
3. Crashlytics.

## 2. Backend service account

Keep the JSON **out of git**. Locally it lives at `backend/serviceAccount.json` (gitignored).

`backend/.env`:

```
FIREBASE_ENABLED=true
FIREBASE_PROJECT_ID=market-place-cfe60
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CREDENTIALS_PATH=./serviceAccount.json
```

Order status changes and admin campaigns send a real FCM push (with sound) plus an in-app inbox row. Rejecting an order requires a reason; that reason is included in the customer notification and shown on order details.

## 3. Web push (admin + customer website)

Need a **Web** app in the same Firebase project, then two values:

### firebaseConfig (`appId` especially)

1. [Firebase Console](https://console.firebase.google.com) → project `market-place-cfe60`
2. Project settings (gear) → **Your apps** → Add app → **Web** (`</>`)
3. Register **two** web apps if you want (Admin + Storefront), or reuse one
4. Copy the `firebaseConfig` object

Paste `appId` (and apiKey if it differs) into:

- `admin/src/environments/environment.ts`
- `web/src/environments/environment.ts`
- `admin/public/firebase-messaging-sw.js`
- `web/public/firebase-messaging-sw.js`

### VAPID key

1. Project settings → **Cloud Messaging**
2. **Web Push certificates**
3. Generate a key pair if none exists
4. Copy the **Key pair** string into `vapidKey` in both environment files

Until `appId` and `vapidKey` are set, web push is skipped; mobile FCM still works.

## 4. iOS APNs

Upload an APNs `.p8` key later under Cloud Messaging. Android does not need that.

## 5. Google / Apple Sign-In

- Android: SHA-1 / SHA-256 of debug and release keystores
- iOS: URL scheme from `REVERSED_CLIENT_ID`
- Apple: App ID with Sign in with Apple + Firebase Apple provider
