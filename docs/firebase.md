# Firebase setup

PlaceMarket can run with **email/password JWT only**. Enable Firebase when you have a project.

## 1. Create / reuse a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com).
2. Add Android app `com.placemarket.placemarket_mobile` and download `google-services.json` into `mobile/android/app/`.
3. Add iOS app with the bundle id from Xcode and put `GoogleService-Info.plist` in `mobile/ios/Runner/`.
4. Enable Authentication providers: Email/Password, Google, Apple.
5. Enable Cloud Messaging.
6. Create a Storage bucket if you later move uploads off local disk.

## 2. Backend service account

1. Project settings → Service accounts → Generate new private key.
2. Do **not** commit the JSON.
3. In `backend/.env`:

```
FIREBASE_ENABLED=true
FIREBASE_PROJECT_ID=...
FIREBASE_CLIENT_EMAIL=...
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

`POST /api/v1/auth/firebase` with `{ "idToken": "..." }` upserts the customer and returns a PlaceMarket JWT.

## 3. Google Sign-In

- Android: SHA-1 / SHA-256 of the debug and release keystores in Firebase.
- iOS: URL scheme from `REVERSED_CLIENT_ID`.
- Enable Google provider in Firebase Auth.

## 4. Apple Sign-In

- Apple Developer: App ID with Sign in with Apple.
- Firebase Auth → Apple provider.
- iOS capability Sign in with Apple in Xcode.

## 5. FCM / APNs

- Upload APNs key (.p8) to Firebase Cloud Messaging.
- Android needs `google-services.json` (already listed above).
- The app registers an FCM token via `PATCH /auth/me` `{ "fcmToken": "..." }`.

Until Firebase is configured, the mobile app still starts: Firebase init is wrapped in try/catch and Google/Apple buttons show an error instead of crashing.
