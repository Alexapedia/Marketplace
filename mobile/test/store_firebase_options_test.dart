import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/repository/firebase/store_firebase_options.dart';

const _base = FirebaseOptions(
  apiKey: 'key',
  appId: '1:1:android:zezo',
  messagingSenderId: '1',
  projectId: 'market-place',
  iosBundleId: 'RK.Marketplace.zezoStore',
);

void main() {
  test('without store values the bundled (Zezo) Firebase app is used', () {
    final options = storeFirebaseOptions(_base, appId: '', iosBundleId: '');
    expect(options.appId, '1:1:android:zezo');
    expect(options.iosBundleId, 'RK.Marketplace.zezoStore');
  });

  test("a store build uses its own Firebase app in the same project", () {
    final options = storeFirebaseOptions(
      _base,
      appId: ' 1:1:android:paytoll ',
      iosBundleId: 'com.example.paytoll',
    );
    expect(options.appId, '1:1:android:paytoll');
    expect(options.iosBundleId, 'com.example.paytoll');
    expect(options.projectId, 'market-place');
    expect(options.apiKey, 'key');
  });
}
