import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/repository/firebase/firebase_service.dart';
import 'core/repository/package_handler/localization_handler.dart';
import 'core/utils/constant/storage_key.dart';
import 'core/utils/functions/responsive.dart';
import 'core/utils/functions/service_locator.dart';
import 'core/utils/functions/shared_preferance_utils.dart';
import 'placemarket_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PreferenceUtils.init();
  await initScreenUtilsFunctions();
  await serviceLocator();
  await FirebaseService.init();
  final lang = PreferenceUtils.getString(StorageKey.lang, 'en');
  runApp(
    localization(
      const PlaceMarketApp(),
      startLocale: Locale(lang.isEmpty ? 'en' : lang),
    ),
  );
}
