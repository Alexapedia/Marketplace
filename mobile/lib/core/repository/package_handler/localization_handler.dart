import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> initLocalization() async {
  await EasyLocalization.ensureInitialized();
}

EasyLocalization localization(Widget app, {Locale? startLocale}) =>
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: startLocale,
      saveLocale: true,
      child: app,
    );

Future<void> changeLanguage(BuildContext context, String lang) async {
  await context.setLocale(Locale(lang));
}

extension Translation on String {
  String get trans => this.tr();
}
