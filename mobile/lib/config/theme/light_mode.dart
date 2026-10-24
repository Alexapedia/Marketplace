import 'package:flutter/material.dart';

import '../../core/models/color_model.dart';
import 'maison.dart';
import 'maison_theme.dart';

/// Maison light theme (ivory canvas). [AppColors.primary] carries the tenant
/// primary and [AppColors.gold] the tenant accent.
ThemeData light(AppColors c) => maisonTheme(
  c,
  Maison.build(
    brightness: Brightness.light,
    primary: c.primary,
    accent: c.gold,
  ),
);
