import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routing/app_router_keys.dart';
import 'maison.dart';

class CircleBackButton extends StatelessWidget {
  const CircleBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCircleButton(
      tooltip: 'a11y_back'.tr(),
      // Mirrors automatically in RTL (matchTextDirection).
      icon: Icons.arrow_back_ios_new_rounded,
      size: 16,
      onPressed:
          onPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRouterKeys.navigatorBarScreen);
            }
          },
    );
  }
}
