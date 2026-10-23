import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/models/api_model.dart';
import 'package:placemarket_mobile/core/utils/functions/safe_emit.dart';
import 'package:placemarket_mobile/modules/pages/categories/controller/categories_cubit.dart';

import 'support/test_locator.dart';

/// Answers GET only when the test completes [pending].
class _SlowApi extends FakeApiConsumer {
  final pending = Completer<Either<String, ApiModel>>();

  @override
  Future<Either<String, ApiModel>> get(String path,
          {Map<String, dynamic>? queryParameters}) =>
      pending.future;
}

class _Counter extends Cubit<int> with SafeEmitMixin<int> {
  _Counter() : super(0);
}

void main() {
  tearDown(tearDownTestLocator);

  test('a cubit with SafeEmitMixin ignores emits after close', () async {
    final cubit = _Counter();
    await cubit.close();
    expect(() => cubit.emit(1), returnsNormally);
    expect(cubit.state, 0);
  });

  test('CategoriesCubit closed mid-load does not throw when the response lands',
      () async {
    final api = _SlowApi();
    await setUpTestLocator(api: api);
    final cubit = CategoriesCubit();
    final load = cubit.load();
    await cubit.close();

    api.pending.complete(right(ApiModel(response: {'data': []}, statusCode: 200)));

    await expectLater(load, completes);
  });
}
