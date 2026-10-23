import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/core/connection/interfaces/api_consumer.dart';
import 'package:placemarket_mobile/core/models/api_model.dart';
import 'package:placemarket_mobile/core/utils/functions/service_locator.dart';

import 'support/test_locator.dart';

class _FavApi implements ApiConsumer {
  final Completer<void> gateA = Completer<void>();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName != #post) return super.noSuchMethod(invocation);
    return _post(invocation.positionalArguments.first as String,
        invocation.namedArguments[#body]);
  }

  Future<Either<String, ApiModel>> _post(String path, dynamic body) async {
    final id = (body as Map)['productId'];
    if (id == 'A') {
      await gateA.future;
      return left('fail');
    }
    return right(ApiModel(response: {'data': {}}, statusCode: 200));
  }
}

void main() {
  tearDown(tearDownTestLocator);

  testWidgets('failure toggling A does not undo a successful toggle of B',
      (tester) async {
    final api = _FavApi();
    await setUpTestLocator(api: api);
    final cubit = AppControllerCubit();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    cubit.emit(cubit.state.copyWith(isGuest: false));
    sl.registerSingleton<AppControllerCubit>(cubit);

    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));

    final a = cubit.toggleFavorite(ctx, 'A');
    await cubit.toggleFavorite(ctx, 'B');
    expect(cubit.state.favoriteIds, containsAll(['A', 'B']));

    api.gateA.complete();
    await a;
    await tester.pump();

    expect(cubit.state.favoriteIds, contains('B'));
    expect(cubit.state.favoriteIds, isNot(contains('A')));
    await cubit.close();
  });
}
