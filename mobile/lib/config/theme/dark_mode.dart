import 'package:flutter/material.dart';

import '../../core/models/color_model.dart';
import 'maison.dart';
import 'maison_theme.dart';

/// Maison dark theme (onyx canvas). The legacy dark [AppColors.primary] is a
/// light-on-dark white, so the tenant primary comes in [brandPrimary].
ThemeData dark(AppColors c, {Color? brandPrimary}) => maisonTheme(
  c,
  Maison.build(
    brightness: Brightness.dark,
    primary: brandPrimary,
    accent: c.gold,
  ),
);
