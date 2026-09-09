import 'package:flutter_test/flutter_test.dart';

import 'package:placemarket_mobile/core/utils/functions/version_compare.dart';

void main() {
  test('version compare detects older builds', () {
    expect(isVersionBelow('1.0.0', '1.0.1'), isTrue);
    expect(isVersionBelow('1.2.0', '1.1.9'), isFalse);
    expect(isVersionBelow('1.0.0', '1.0.0'), isFalse);
  });
}
