import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../placemarket_app.dart';

class AppToast {
  AppToast(
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final context = PlaceMarketApp.navigatorKey.currentContext;
    if (context == null) return;
    final scheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          message.tr(),
          style: isError ? TextStyle(color: scheme.onError) : null,
        ),
        backgroundColor: isError ? scheme.error : null,
        behavior: SnackBarBehavior.floating,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: isError ? scheme.onError : null,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
