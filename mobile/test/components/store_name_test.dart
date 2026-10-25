// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/core/utils/constant/storage_key.dart';
import 'package:placemarket_mobile/core/utils/functions/shared_preferance_utils.dart';
import 'package:placemarket_mobile/core/utils/functions/store_name.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<String> _nameShown(WidgetTester tester, {String brandName = ''}) async {
  final cubit = AppControllerCubit()
    ..emit(const AppControllerState().copyWith(brandName: brandName));
  addTearDown(cubit.close);
  late String shown;
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _NoAssets(),
      fallbackLocale: const Locale('en'),
      child: BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              shown = storeName(context);
              return const SizedBox();
            },
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
  }
  return shown;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({StorageKey.brandName: 'PayToll'});
    await PreferenceUtils.init();
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('the store name comes from the store config', (tester) async {
    expect(await _nameShown(tester, brandName: 'PayToll'), 'PayToll');
  });

  testWidgets('falls back to the bundled app_name when the store has none', (
    tester,
  ) async {
    expect(await _nameShown(tester), 'app_name');
  });

  test('the last store name is restored before the config loads', () async {
    final cubit = AppControllerCubit()..restoreBrand();
    addTearDown(cubit.close);
    expect(cubit.state.brandName, 'PayToll');
  });

  test('translations never hard-code a store name outside app_name', () {
    for (final lang in ['en', 'ar']) {
      final map =
          jsonDecode(File('assets/translations/$lang.json').readAsStringSync())
              as Map<String, dynamic>;
      final appName = map['app_name'] as String;
      for (final entry in map.entries) {
        if (entry.key == 'app_name' || entry.value is! String) continue;
        expect(
          (entry.value as String).contains(appName),
          isFalse,
          reason: '$lang.${entry.key} should use {store}',
        );
      }
    }
  });
}
