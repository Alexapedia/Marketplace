import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';

/// This store's Firebase app id (`--dart-define=FIREBASE_APP_ID=...`), for the
/// platform being built. Empty: the bundled Zezo app.
const String _storeAppId = String.fromEnvironment('FIREBASE_APP_ID');
const String _storeIosBundleId = String.fromEnvironment(
  'FIREBASE_IOS_BUNDLE_ID',
);

/// [base] with this store's Firebase app swapped in. Every store app is
/// registered in the same Firebase project, so key, sender and project stay.
FirebaseOptions storeFirebaseOptions(
  FirebaseOptions base, {
  String appId = _storeAppId,
  String iosBundleId = _storeIosBundleId,
}) {
  final id = appId.trim();
  final bundle = iosBundleId.trim();
  if (id.isEmpty && bundle.isEmpty) return base;
  return base.copyWith(
    appId: id.isEmpty ? null : id,
    iosBundleId: bundle.isEmpty ? null : bundle,
  );
}

/// Options for `Firebase.initializeApp` in this store's build.
FirebaseOptions get currentStoreFirebaseOptions =>
    storeFirebaseOptions(DefaultFirebaseOptions.currentPlatform);
