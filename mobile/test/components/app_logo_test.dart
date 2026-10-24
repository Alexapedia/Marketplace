// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/app_logo.dart';
import 'package:placemarket_mobile/core/models/app_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/constant/app_string.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> _pump(
  WidgetTester tester, {
  String logo = '',
  String logoDark = '',
  bool darkTheme = false,
  bool? onDarkSurface,
}) async {
  final cubit = AppControllerCubit()
    ..emit(
      const AppControllerState().copyWith(
        brandLogo: logo,
        brandLogoDark: logoDark,
      ),
    );
  addTearDown(cubit.close);
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _NoAssets(),
      fallbackLocale: const Locale('en'),
      child: Builder(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: darkTheme
                ? dark(AppColors.darkDefaults)
                : light(AppColors.lightDefaults),
            home: Scaffold(
              body: Center(
                child: AppLogo(height: 40, onDarkSurface: onDarkSurface),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.byType(Scaffold).evaluate().isNotEmpty) break;
  }
  // Let a theme change (AnimatedTheme) finish.
  for (var i = 0; i < 2; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

String? _assetName() {
  final img = find.byType(Image).evaluate().map((e) => e.widget as Image);
  for (final i in img) {
    final p = i.image;
    if (p is AssetImage) return p.assetName;
  }
  return null;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('app config parses branding.logo and branding.logoDark', () {
    final config = AppConfigModel.fromJson({
      'data': {
        'tenant': {
          'branding': {
            'name': 'Zezo',
            'logo': '/uploads/logo.png',
            'logoDark': '/uploads/logo-dark.png',
          },
        },
      },
    });
    expect(config.tenant!.logo, '/uploads/logo.png');
    expect(config.tenant!.logoDark, '/uploads/logo-dark.png');
    final empty = AppConfigModel.fromJson({
      'data': {
        'tenant': {'branding': {}},
      },
    });
    expect(empty.tenant!.logo, '');
    expect(empty.tenant!.logoDark, '');
  });

  testWidgets('no tenant logo: bundled asset for the surface', (tester) async {
    await _pump(tester);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(_assetName(), AppString.logoLight);
    await _pump(tester, darkTheme: true);
    expect(_assetName(), AppString.logoDark);
  });

  testWidgets('tenant logo: network image on light surfaces', (tester) async {
    await _pump(
      tester,
      logo: 'https://cdn.example.com/logo.png',
      logoDark: 'https://cdn.example.com/logo-dark.png',
    );
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(img.imageUrl, 'https://cdn.example.com/logo.png');
  });

  testWidgets('logoDark is used on dark surfaces when present', (tester) async {
    await _pump(
      tester,
      logo: 'https://cdn.example.com/logo.png',
      logoDark: 'https://cdn.example.com/logo-dark.png',
      onDarkSurface: true,
    );
    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      'https://cdn.example.com/logo-dark.png',
    );
    // No dark variant: falls back to the main logo.
    await _pump(
      tester,
      logo: 'https://cdn.example.com/logo.png',
      darkTheme: true,
    );
    expect(
      tester
          .widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl,
      'https://cdn.example.com/logo.png',
    );
  });

  testWidgets('a failing network logo falls back to the bundled asset', (
    tester,
  ) async {
    await _pump(tester, logo: 'https://cdn.example.com/broken.png');
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final context = tester.element(find.byType(CachedNetworkImage));
    final fallback = img.errorWidget!(context, img.imageUrl, Exception('404'));
    expect(fallback, isA<Image>());
    expect(
      ((fallback as Image).image as AssetImage).assetName,
      AppString.logoLight,
    );
  });

  test('relative logo paths resolve against the API origin', () {
    final url = AppLogo.networkFor(
      darkSurface: false,
      logo: '/uploads/logo.png',
      logoDark: '',
    );
    expect(url, endsWith('/uploads/logo.png'));
    expect(url, startsWith('http'));
  });
}
