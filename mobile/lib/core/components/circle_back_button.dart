import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routing/app_router_keys.dart';

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.92)
            : Colors.black.withValues(alpha: 0.92),
        foregroundColor: onSurface,
        minimumSize: const Size(36, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed:
          onPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRouterKeys.navigatorBarScreen);
            }
          },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 16,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
      ),
    );
  }
}
