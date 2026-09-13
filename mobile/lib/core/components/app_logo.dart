import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../utils/constant/app_string.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 64,
    this.width,
    this.onDarkSurface,
  });

  final double height;
  final double? width;

  /// `true` forces the white mark (navy/dark surfaces).
  /// `false` forces the navy mark (light surfaces).
  /// `null` follows the current theme brightness.
  final bool? onDarkSurface;

  static String assetFor(BuildContext context, {bool? onDarkSurface}) {
    final useWhite =
        onDarkSurface ?? Theme.of(context).brightness == Brightness.dark;
    return useWhite ? AppString.logoDark : AppString.logoLight;
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetFor(context, onDarkSurface: onDarkSurface),
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'app_name'.tr(),
    );
  }
}
