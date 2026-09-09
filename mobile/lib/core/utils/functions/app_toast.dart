import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../placemarket_app.dart';

class AppToast {
  AppToast(String message, {bool isError = false}) {
    final context = PlaceMarketApp.navigatorKey.currentContext;
    if (context == null) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message.tr()),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
