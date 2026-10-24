# Adding a new store

One codebase serves every store. The backend picks the store from the request host (website, admin) or from the `X-Tenant` header (mobile). A new store therefore needs **data** (the store in the holder), **DNS**, and for mobile **one flavor**: no forked code.

Each store is set up on its own short-lived branch, so a mistake stays there until it is tested:

```bash
git checkout main && git pull
git checkout -b store/<slug>        # e.g. store/paytoll
```

Steps marked **(you)** need your own accounts, keys or DNS.

## 1. The store (holder)

1. Holder → Stores → New: name, `slug` (lowercase, used everywhere below), first admin, brand colours.
2. Store page → Branding: logo (light and dark), favicon (square), mobile splash image. Save.
3. Hosts, written exactly as typed in the browser (port included when there is one):

| Where | Website | Admin |
|---|---|---|
| Local dev | `<slug>.localhost:5173` | `<slug>.localhost:4200` |
| Production | `shop.<domain>` | `admin.<domain>` |

`*.localhost` works in Chrome with no setup. A host that matches nothing falls back to the default store.

## 2. Website and admin

No build per store. The same `web` and `admin` builds serve every host.

- **(you)** DNS: point both production hosts at the server (A or CNAME). With the cloudflared tunnel, add an ingress rule per host.
- **(you)** TLS certificate for each host.

## 3. Mobile flavor

### Android

In `mobile/android/app/build.gradle.kts`, add the store inside `productFlavors`:

```kotlin
create("<slug>") {
    dimension = "store"
    applicationId = "com.yourcompany.<slug>"   // final: cannot change after publishing
    resValue("string", "app_name", "<Store Name>")
    signingConfig = storeSigning("<slug>")
}
```

- Launcher icons: put `ic_launcher.png` files in `mobile/android/app/src/<slug>/res/mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/`. They replace the default icons for this flavor only.
- **(you)** Firebase console → project `market-place-cfe60` → add an Android app with that application id → download `google-services.json` to `mobile/android/app/src/<slug>/`. The build fails without it.
- **(you)** Upload key: create a keystore and keep it outside git (and backed up). Then create `mobile/android/keys/<slug>.properties` (ignored by git):

```properties
storeFile=/absolute/path/to/<slug>-upload.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

```bash
keytool -genkeypair -v -keystore <slug>-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

### iOS

```bash
cd mobile
ruby ios/scripts/add_store_flavor.rb <slug> com.yourcompany.<slug> "<Store Name>" AppIcon-<slug>
cd ios && pod install
```

- App icon: in Xcode, `Runner/Assets.xcassets` → add an App Icon set named `AppIcon-<slug>` with the store's icon. Leave out the last argument to reuse the default `AppIcon`.
- **(you)** Apple Developer → Identifiers: register the bundle id, with Push Notifications and Sign in with Apple. In Xcode → Runner → Signing & Capabilities, pick your team for the `*-<slug>` configurations.
- **(you)** Firebase console → add an iOS app with that bundle id. Note its **App ID** (`1:…:ios:…`).

### Build settings per store

| `--dart-define` | Value |
|---|---|
| `TENANT_SLUG` | the store slug |
| `API_URL` | `https://api.<domain>/api/v1` |
| `FIREBASE_APP_ID` | that platform's Firebase App ID (Android or iOS) |
| `FIREBASE_IOS_BUNDLE_ID` | iOS only: the bundle id |

Try it on an emulator first:

```bash
flutter run --flavor <slug> --dart-define=TENANT_SLUG=<slug>
```

The store's name, colours, logo and products should show.

## 4. Build and upload

```bash
cd mobile
flutter build appbundle --release --flavor <slug> \
  --dart-define=TENANT_SLUG=<slug> \
  --dart-define=API_URL=https://api.<domain>/api/v1 \
  --dart-define=FIREBASE_APP_ID=<android app id>

flutter build ipa --release --flavor <slug> \
  --dart-define=TENANT_SLUG=<slug> \
  --dart-define=API_URL=https://api.<domain>/api/v1 \
  --dart-define=FIREBASE_APP_ID=<ios app id> \
  --dart-define=FIREBASE_IOS_BUNDLE_ID=com.yourcompany.<slug>
```

- **(you)** Google Play Console → Create app (one per store) → upload `build/app/outputs/bundle/<slug>Release/app-<slug>-release.aab`. Store listing, privacy policy and content rating are per app.
- **(you)** App Store Connect → New App with the bundle id → upload `build/ios/ipa/*.ipa` with Transporter or Xcode Organizer.
- Version: `version` in `mobile/pubspec.yaml`. Raise the build number for every upload.

## 5. Finish

Commit the flavor files on `store/<slug>`, then open a pull request into `main`. The default store (`zezo`) keeps its current ids, so its existing listings are unaffected.

## What changes per store

| | Where |
|---|---|
| Name, colours, logo, favicon, splash | Holder (live, no rebuild) |
| Website and admin domains | Holder + DNS |
| App id, app name, icon, signing | Mobile flavor (Android block + iOS script) |
| Store, API, Firebase app | `--dart-define` at build time |
