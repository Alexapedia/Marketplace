import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/utils/constant/app_enum.dart';
import 'package:placemarket_mobile/modules/pages/checkout/controller/check_out_cubit.dart';

import 'package:placemarket_mobile/core/models/api_model.dart';

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

  testWidgets(
      'submit sends an Idempotency-Key header that stays the same across retries of one checkout',
      (tester) async {
    final api = FakeApiConsumer();
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

    await cubit.submit(ctx);
    await cubit.submit(ctx);

    expect(api.calls.length, 2);
    final k1 = api.calls[0].headers?['Idempotency-Key'] as String?;
    final k2 = api.calls[1].headers?['Idempotency-Key'] as String?;
    expect(k1, isNotNull);
    expect(k1, matches(RegExp(r'^mobile-\d+-[a-z0-9]{8}$')));
    expect(k2, k1);
  });

  testWidgets('a second submit while the first is in flight sends nothing',
      (tester) async {
    final api = _SlowApi();
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

    final first = cubit.submit(ctx);
    final second = cubit.submit(ctx);
    await tester.pump();
    expect(api.calls.length, 1);

    api.gate.complete(left('fake_failure'));
    await first;
    await second;
    expect(api.calls.length, 1);
  });
}

class _SlowApi extends FakeApiConsumer {
  final gate = Completer<Either<String, ApiModel>>();
  @override
  Future<Either<String, ApiModel>> post(String path,
      {dynamic body,
      Map<String, dynamic>? queryParameters,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? headers}) {
    calls.add((method: 'POST', path: path, body: body, headers: headers));
    return gate.future;
  }
}
