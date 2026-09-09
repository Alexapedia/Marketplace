# Mobile store builds

## Android

1. Place `google-services.json` in `mobile/android/app/` when Firebase is ready.
2. Confirm `INTERNET` permission in `AndroidManifest.xml`.
3. Create a release keystore (keep it out of git).
4. Build:

```bash
cd mobile
flutter pub get
flutter build appbundle --release --dart-define=API_URL=https://api.your-domain.com/api/v1
```

Upload the `.aab` to Google Play. Set `version` in `pubspec.yaml` (`1.0.0+1` → versionName / versionCode).

## iOS

1. Open `mobile/ios/Runner.xcworkspace` in Xcode.
2. Set signing team, bundle id, and capabilities: Sign in with Apple, Push Notifications.
3. Add `GoogleService-Info.plist` and photo-library usage strings (already requested in Info.plist).
4. Build:

```bash
cd mobile
flutter build ipa --release --dart-define=API_URL=https://api.your-domain.com/api/v1
```

Force-upgrade store URLs are configured in the admin **App / Force Upgrade** page.

## Admin dashboard build

```bash
cd admin
npm ci
npx ng build --configuration=production
```

Serve `admin/dist/admin/browser` behind HTTPS. Point `environment.apiUrl` at the production API before building (add `environment.prod.ts` when the domain is known).
