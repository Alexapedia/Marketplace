import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/image_item.dart';
import 'package:placemarket_mobile/core/models/app_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_summary.dart';
import 'package:placemarket_mobile/modules/pages/home/controller/ads_pager_cubit.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/ads_carousel.dart';

const _ads = [
  BannerModel(id: 'a', title: 'A'),
  BannerModel(id: 'b', title: 'B'),
  BannerModel(id: 'c', title: 'C'),
];

class _NoAssets extends AssetLoader {
  const _NoAssets();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Widget _app(Widget child, {bool reduce = false}) => EasyLocalization(
  supportedLocales: const [Locale('en')],
  path: 'assets/translations',
  assetLoader: const _NoAssets(),
  fallbackLocale: const Locale('en'),
  child: Builder(
    builder: (context) => MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: light(AppColors.lightDefaults),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: c!,
      ),
      home: screenUtilHandler(
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  ),
);

Future<AdsPagerCubit> _pumpCarousel(
  WidgetTester tester, {
  bool reduce = false,
}) async {
  final cubit = AdsPagerCubit();
  await tester.pumpWidget(
    _app(
      BlocProvider.value(
        value: cubit,
        child: const AdsCarousel(ads: _ads),
      ),
      reduce: reduce,
    ),
  );
  await _load(tester);
  await tester.pump();
  return cubit;
}

Future<void> _end(WidgetTester tester, AdsPagerCubit cubit) async {
  await tester.pumpWidget(const SizedBox());
  await cubit.close();
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _load(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (find.byType(Scaffold).evaluate().isNotEmpty) break;
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('carousel does not auto-advance when reduceMotion', (
    tester,
  ) async {
    final cubit = await _pumpCarousel(tester, reduce: true);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state, 0);
    expect(cubit.isRunning, isFalse);
    await _end(tester, cubit);
  });

  testWidgets('carousel auto-advances normally without reduceMotion', (
    tester,
  ) async {
    final cubit = await _pumpCarousel(tester);
    await tester.pump(const Duration(seconds: 4, milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state, 1);
    await _end(tester, cubit);
  });

  testWidgets('carousel dots are 48dp targets that jump to the page', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final cubit = await _pumpCarousel(tester);
    final dot = find.bySemanticsLabel('a11y_go_to_slide');
    expect(dot, findsNWidgets(3));
    final size = tester.getSize(dot.at(2));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await tester.tap(dot.at(2));
    await tester.pumpAndSettle();
    expect(cubit.state, 2);
    handle.dispose();
    await _end(tester, cubit);
  });

  testWidgets('pause control toggles auto-advance and announces state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final cubit = await _pumpCarousel(tester);
    expect(cubit.isRunning, isTrue);
    expect(find.bySemanticsLabel('a11y_carousel_playing'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('carousel-pause')));
    await _load(tester);
    expect(cubit.isRunning, isFalse);
    expect(find.bySemanticsLabel('a11y_carousel_paused'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(cubit.state, 0);
    await tester.tap(find.byKey(const ValueKey('carousel-pause')));
    await _load(tester);
    expect(cubit.isRunning, isTrue);
    handle.dispose();
    await _end(tester, cubit);
  });

  testWidgets(
    'ImageItem placeholder animates and is static under reduceMotion',
    (tester) async {
      Future<Decoration?> sample(bool reduce) async {
        await tester.pumpWidget(
          _app(const ImageShimmer(width: 100, height: 100), reduce: reduce),
        );
        await _load(tester);
        final box = find.byKey(const ValueKey('image-shimmer'));
        expect(box, findsOneWidget);
        final a = tester.widget<DecoratedBox>(box).decoration;
        await tester.pump(const Duration(milliseconds: 600));
        final b = tester.widget<DecoratedBox>(box).decoration;
        return a == b ? null : b;
      }

      expect(await sample(false), isNotNull);
      expect(await sample(true), isNull);
    },
  );

  testWidgets('ImageItem passes memCacheWidth for a finite width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const ImageItem(
          'https://example.invalid/x.png',
          width: 100,
          height: 100,
        ),
      ),
    );
    await _load(tester);
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(img.memCacheWidth, (100 * tester.view.devicePixelRatio).round());
  });

  testWidgets('no emoji in cart summary', (tester) async {
    await tester.pumpWidget(
      _app(const CartSummary(total: 10, canCheckout: true)),
    );
    await _load(tester);
    await tester.pump(const Duration(seconds: 2));
    final texts = tester.widgetList<Text>(find.byType(Text));
    expect(texts.any((t) => (t.data ?? '').contains('💵')), isFalse);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
  });
}
