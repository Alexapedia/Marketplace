import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/product_hero.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('the card hands its hero tag to the details screen once', () {
    ProductHero.prime('p9', 'featured-0-img-p9', 'img.jpg');
    final claimed = ProductHero.claim('p9');
    expect(claimed.tag, 'featured-0-img-p9');
    expect(claimed.image, 'img.jpg');
    // Deep links (no card) fall back to a stable tag.
    expect(ProductHero.claim('p9').tag, 'product-p9');
  });

  testWidgets('tapping a card primes the shared image tag for its product', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    const product = ProductModel(id: 'p1', name: 'Vase', price: 100);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: Center(
              child: SizedBox(
                width: 180,
                height: 290,
                child: ProductCard(product: product, heroScope: 'grid-3'),
              ),
            ),
          ),
        ),
        GoRoute(
          name: 'product_details',
          path: '/productDetails',
          builder: (_, _) => const Scaffold(body: Text('details')),
        ),
      ],
    );
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en')],
        path: 'assets/translations',
        assetLoader: const _NoAssets(),
        fallbackLocale: const Locale('en'),
        child: Builder(
          builder: (context) => BlocProvider(
            create: (_) => AppControllerCubit(),
            child: screenUtilHandler(
              child: MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                theme: light(AppColors.lightDefaults),
                routerConfig: router,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // The image is the Hero the details screen will land on.
    expect(
      find.byWidgetPredicate((w) => w is Hero && w.tag == 'grid-3-img-p1'),
      findsOneWidget,
    );
    await tester.tap(find.byType(ProductCard));
    await tester.pump();
    expect(ProductHero.claim('p1').tag, 'grid-3-img-p1');
    await tester.pumpAndSettle();
  });
}
