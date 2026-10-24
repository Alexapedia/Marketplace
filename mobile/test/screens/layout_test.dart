import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/models/app_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/core/utils/functions/service_locator.dart';
import 'package:placemarket_mobile/modules/auth/login/controller/login_cubit.dart';
import 'package:placemarket_mobile/modules/auth/login/view/login_screen.dart';
import 'package:placemarket_mobile/modules/auth/login/view/widgets/login_form.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/view/navigation_bar_screen.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/cart_screen.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_item_tile.dart';
import 'package:placemarket_mobile/modules/pages/checkout/view/checkout_screen.dart';
import 'package:placemarket_mobile/modules/pages/orders/view/widgets/order_tile.dart';
import 'package:placemarket_mobile/modules/pages/product_details/view/product_details_screen.dart';
import 'package:placemarket_mobile/modules/pages/product_details/view/widgets/product_info.dart';
import 'package:placemarket_mobile/modules/pages/profile/view/widgets/profile_tile.dart';
import 'package:placemarket_mobile/modules/pages/products/view/products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/layout_fixtures.dart';
import '../support/offline_cache.dart';
import '../support/test_locator.dart';

/// Phone, small phone, tablet and large tablet (logical px, dpr 1).
const _sizes = <String, Size>{
  '360x740': Size(360, 740),
  '390x844': Size(390, 844),
  '768x1024': Size(768, 1024),
  '1024x1366': Size(1024, 1366),
};

Widget _tab(int i) => BlocProvider(
  create: (_) => NavigationBarCubit()..getPageIndex(i),
  child: const NavigationBarScreen(),
);

/// What each screen must actually show, so a silent empty/error state cannot
/// make the overflow check pass vacuously.
final _expects = <String, Finder Function()>{
  'home': () => find.byType(ProductCard),
  'orders': () => find.byType(OrderTile),
  'profile': () => find.byType(ProfileTile),
  'products': () => find.byType(ProductCard),
  'product details': () => find.byType(ProductInfo),
  'cart': () => find.byType(CartItemTile),
  'checkout': () => find.textContaining('Sara Al-Harbi'),
  'login': () => find.byType(LoginForm),
};

final _screens = <String, Widget Function()>{
  'home': () => _tab(0),
  'orders': () => _tab(2),
  'profile': () => _tab(3),
  'products': () => const ProductsScreen(title: 'Perfumes'),
  'product details': () => const ProductDetailsScreen(productId: 'p1'),
  'cart': () => const CartScreen(),
  'checkout': () => const CheckOutScreen(),
  'login': () =>
      BlocProvider(create: (_) => LoginCubit(), child: const LoginScreen()),
};

Future<void> _loadFonts() async {
  Future<ByteData> f(String p) async =>
      ByteData.view((await File(p).readAsBytes()).buffer);
  final plex = FontLoader('IBMPlexSansArabic');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    plex.addFont(f('assets/fonts/IBMPlexSansArabic-$w.ttf'));
  }
  await plex.load();
  await (FontLoader(
    'PlayfairDisplay',
  )..addFont(f('assets/fonts/PlayfairDisplay-Variable.ttf'))).load();
  await (FontLoader(
    'ElMessiri',
  )..addFont(f('assets/fonts/ElMessiri-Variable.ttf'))).load();
}

class _FileAssets extends AssetLoader {
  const _FileAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final text = await File(
      'assets/translations/${locale.languageCode}.json',
    ).readAsString();
    return (await _decode(text));
  }
}

Future<Map<String, dynamic>> _decode(String text) async =>
    (const JsonDecoder().convert(text) as Map).cast<String, dynamic>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFonts();
    // Images fail fast (offline) instead of using the real cache manager.
    CachedNetworkImageProvider.defaultCacheManager = OfflineCacheManager();
  });

  for (final lang in ['en', 'ar']) {
    for (final size in _sizes.entries) {
      for (final screen in _screens.entries) {
        testWidgets(
          '${screen.key} lays out without overflow at ${size.key} ($lang)',
          (tester) async {
            SharedPreferences.setMockInitialValues({});
            PackageInfo.setMockInitialValues(
              appName: 'Zezo',
              packageName: 'x.y',
              version: '1.0.0',
              buildNumber: '1',
              buildSignature: '',
            );
            await EasyLocalization.ensureInitialized();
            await setUpTestLocator(api: LayoutApi());
            final app = AppControllerCubit()
              ..emit(
                const AppControllerState().copyWith(
                  isGuest: false,
                  cartItemsCount: 3,
                  countOfUnReadNot: 2,
                  favoritesReady: true,
                  user: const UserModel(
                    name: 'Sara Al-Harbi',
                    email: 'sara@example.com',
                  ),
                ),
              );
            sl.registerSingleton<AppControllerCubit>(app);
            tester.view.physicalSize = size.value;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            addTearDown(app.close);

            final router = GoRouter(
              routes: [GoRoute(path: '/', builder: (_, _) => screen.value())],
            );
            await tester.pumpWidget(
              EasyLocalization(
                supportedLocales: const [Locale('en'), Locale('ar')],
                path: 'assets/translations',
                assetLoader: const _FileAssets(),
                fallbackLocale: const Locale('en'),
                startLocale: Locale(lang),
                useOnlyLangCode: true,
                saveLocale: false,
                child: Builder(
                  builder: (context) => BlocProvider.value(
                    value: app,
                    child: screenUtilHandler(
                      child: MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        locale: context.locale,
                        theme: light(AppColors.lightDefaults),
                        darkTheme: dark(AppColors.darkDefaults),
                        routerConfig: router,
                      ),
                    ),
                  ),
                ),
              ),
            );
            // Let the fake API answer and entrances finish.
            for (var i = 0; i < 12; i++) {
              await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 20)),
              );
              await tester.pump(const Duration(milliseconds: 150));
            }
            await tester.pump(const Duration(seconds: 2));

            final errors = <Object>[];
            Object? e;
            while ((e = tester.takeException()) != null) {
              errors.add(e!);
            }
            expect(errors, isEmpty, reason: errors.join('\n---\n'));
            expect(
              _expects[screen.key]!(),
              findsWidgets,
              reason: '${screen.key} rendered no content',
            );

            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 6));
          },
        );
      }
    }
  }
}
