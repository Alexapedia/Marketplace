import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/utils/constant/app_enum.dart';
import 'package:placemarket_mobile/modules/pages/checkout/controller/check_out_cubit.dart';

import 'support/test_locator.dart';

void main() {
  tearDown(tearDownTestLocator);

  testWidgets(
      'checkout submit posts addressId, notes, paymentMethod COD, channel mobile to /orders',
      (tester) async {
    final api = FakeApiConsumer(); // postResult defaults to a failure (no navigation)
    await setUpTestLocator(api: api);

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));

    final cubit = CheckOutCubit();
    addTearDown(cubit.close);
    cubit.select('addr1');
    cubit.notes.text = '  leave at door ';

    await cubit.submit(ctx);

    expect(api.calls.length, 1);
    expect(api.calls.single.method, 'POST');
    expect(api.calls.single.path, '/orders');
    expect(api.calls.single.body, {
      'addressId': 'addr1',
      'notes': 'leave at door',
      'paymentMethod': 'COD',
      'channel': 'mobile',
    });
    expect(cubit.state.status, RequestStatus.failed);
    expect(cubit.state.error, 'fake_failure');
  });
}
