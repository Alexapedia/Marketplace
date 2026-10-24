// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/core/models/app_models.dart';
import 'package:placemarket_mobile/modules/common/splash/view/widgets/splash_image.dart';

const _fallbackKey = Key('splash-fallback');

Future<void> _pump(WidgetTester tester, {String splash = ''}) async {
  final cubit = AppControllerCubit()
    ..emit(const AppControllerState().copyWith(brandSplash: splash));
  addTearDown(cubit.close);
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: const MaterialApp(
        home: SplashImage(fallback: SizedBox(key: _fallbackKey)),
      ),
    ),
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('app config parses branding.splash', () {
    final config = AppConfigModel.fromJson({
      'data': {
        'tenant': {
          'branding': {'splash': '/uploads/splash.png'},
        },
      },
    });
    expect(config.tenant!.splash, '/uploads/splash.png');
    final empty = AppConfigModel.fromJson({
      'data': {
        'tenant': {'branding': {}},
      },
    });
    expect(empty.tenant!.splash, '');
  });

  testWidgets('no store splash: the built-in splash is shown', (tester) async {
    await _pump(tester);
    expect(find.byKey(_fallbackKey), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsNothing);
  });

  testWidgets('store splash: full-screen network image', (tester) async {
    await _pump(tester, splash: 'https://cdn.example.com/splash.png');
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(img.imageUrl, 'https://cdn.example.com/splash.png');
    expect(img.fit, BoxFit.cover);
  });

  testWidgets('a failing splash image falls back to the built-in splash', (
    tester,
  ) async {
    await _pump(tester, splash: 'https://cdn.example.com/broken.png');
    final img = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final context = tester.element(find.byType(CachedNetworkImage));
    final fallback = img.errorWidget!(context, img.imageUrl, Exception('404'));
    expect(fallback.key, _fallbackKey);
  });
}
