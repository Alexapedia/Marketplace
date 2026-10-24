import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme/maison.dart';
import '../../../placemarket_app.dart';

/// Themed toast: ink surface (surface-2 in dark) with a status icon; errors
/// use the danger colour with a computed on-colour. Rises in over `base` and
/// leaves faster (the SnackBar animation controls the timing).
class AppToast {
  AppToast(
    String message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final context = PlaceMarketApp.navigatorKey.currentContext;
    if (context == null) return;
    final m = context.maison;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final bg = isError ? m.danger : (m.isDark ? m.surface2 : m.ink);
    final fg = isError
        ? Maison.onColor(m.danger)
        : (m.isDark ? m.ink : Maison.white);
    if (isError) HapticFeedback.mediumImpact();
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 20,
              color: isError ? fg : m.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: fg),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: isError ? fg : m.accent,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
