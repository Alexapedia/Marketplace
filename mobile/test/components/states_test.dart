import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/failed_shape.dart';
import 'package:placemarket_mobile/core/connection/concept/exceptions.dart';
import 'package:placemarket_mobile/core/connection/interfaces/api_consumer.dart';
import 'package:placemarket_mobile/core/models/api_model.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/constant/app_enum.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/core/utils/functions/service_locator.dart';
import 'package:placemarket_mobile/modules/pages/home/controller/home_cubit.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/home_body.dart';
import 'package:placemarket_mobile/modules/pages/products/controller/products_cubit.dart';
import 'package:placemarket_mobile/modules/pages/products/view/widgets/products_body.dart';

class _FakeApi extends Fake implements ApiConsumer {
  @override
  Future<Either<String, ApiModel>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async => right(ApiModel(response: {'data': <dynamic>[]}, statusCode: 200));
}

class _SeedProducts extends ProductsCubit {
  void seed(ProductsState s) => emit(s);
}

class _SeedHome extends HomeCubit {
  void seed(HomeState s) => emit(s);
}

Widget _app(Widget home) => BlocProvider(
  create: (_) => AppControllerCubit(),
  child: MaterialApp(
    theme: light(AppColors.lightDefaults),
    home: screenUtilHandler(child: home),
  ),
);

void main() {
  Future<void> pumpShape(
    WidgetTester tester,
    String msg, {
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: FailedShape(msg: msg, onTapRefresh: onTap ?? () {}),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('offline message shows wifi_off icon', (tester) async {
    await pumpShape(tester, NoInternetConnectionException().toString());
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    // Timeouts surface as FetchDataException and are also treated as offline.
    await pumpShape(tester, FetchDataException().toString());
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });

  testWidgets('server message shows cloud_off icon', (tester) async {
    await pumpShape(tester, InternalServerException().toString());
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('generic message shows error_outline icon', (tester) async {
    await pumpShape(tester, BadRequestException('Bad thing').toString());
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });

  testWidgets('retry is a labeled tonal button that calls onTapRefresh', (
    tester,
  ) async {
    var taps = 0;
    await pumpShape(tester, 'oops', onTap: () => taps++);
    expect(find.bySubtype<FilledButton>(), findsOneWidget);
    expect(find.text('try_again'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    await tester.tap(find.bySubtype<FilledButton>());
    expect(taps, 1);
  });

  testWidgets(
    'products empty with active filters shows a clear filters action',
    (tester) async {
      if (sl.isRegistered<ApiConsumer>()) sl.unregister<ApiConsumer>();
      sl.registerSingleton<ApiConsumer>(_FakeApi());
      addTearDown(() => sl.unregister<ApiConsumer>());
      final cubit = _SeedProducts();
      addTearDown(cubit.close);
      cubit.seed(
        const ProductsState(status: RequestStatus.loaded, sort: 'price'),
      );
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: BlocProvider<ProductsCubit>.value(
              value: cubit,
              child: const ProductsBody(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('empty_products_filtered'), findsOneWidget);
      expect(cubit.state.hasFilters, isTrue);
      await tester.tap(find.widgetWithText(TextButton, 'clear_filters'));
      await tester.pump();
      expect(cubit.state.hasFilters, isFalse);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('home failure fills the viewport', (tester) async {
    final cubit = _SeedHome();
    addTearDown(cubit.close);
    cubit.seed(const HomeState(status: RequestStatus.failed, error: 'oops'));
    await tester.pumpWidget(
      _app(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeBody()),
      ),
    );
    await tester.pump();
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final center = tester.getCenter(find.byType(FailedShape));
    expect(center.dy, closeTo(screen.height / 2, screen.height * 0.15));
  });
}
