import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/connection/concept/end_points.dart';

void main() {
  test('every request says it comes from the mobile app', () {
    expect(EndPoints.clientHeaders(slug: ''), {'X-Client': 'mobile'});
  });

  test('a store build also names its store with X-Tenant', () {
    expect(EndPoints.clientHeaders(slug: ' paytoll '), {
      'X-Client': 'mobile',
      'X-Tenant': 'paytoll',
    });
  });

  test('without TENANT_SLUG the default store is used, as before', () {
    expect(EndPoints.tenantSlug, '');
    expect(EndPoints.clientHeaders().containsKey('X-Tenant'), isFalse);
  });
}
