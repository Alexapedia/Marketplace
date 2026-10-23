import 'package:flutter/material.dart';

const String kFontFamily = 'IBMPlexSansArabic';

/// Full M3 text theme. Sizes (sp): 32/28/24/20/18/16/14/14/12/12 for
/// display/headline/title/body/label tiers; line height 1.4 body, 1.2 titles.
TextTheme buildTextTheme({required Color onSurface, required Color secondary}) {
  TextStyle s(
    double size,
    FontWeight w,
    double height, [
    Color? color,
  ]) => TextStyle(
    fontFamily: kFontFamily,
    fontSize: size,
    fontWeight: w,
    height: height,
    color: color ?? onSurface,
  );

  return TextTheme(
    displayLarge: s(32, FontWeight.w700, 1.2),
    displayMedium: s(28, FontWeight.w700, 1.2),
    displaySmall: s(24, FontWeight.w700, 1.2),
    headlineLarge: s(28, FontWeight.w700, 1.2),
    headlineMedium: s(24, FontWeight.w700, 1.2),
    headlineSmall: s(20, FontWeight.w600, 1.2),
    titleLarge: s(20, FontWeight.w600, 1.2),
    titleMedium: s(18, FontWeight.w600, 1.2),
    titleSmall: s(16, FontWeight.w500, 1.2),
    bodyLarge: s(16, FontWeight.w400, 1.4),
    bodyMedium: s(14, FontWeight.w400, 1.4),
    bodySmall: s(12, FontWeight.w400, 1.4, secondary),
    labelLarge: s(14, FontWeight.w600, 1.4),
    labelMedium: s(12, FontWeight.w500, 1.4),
    labelSmall: s(12, FontWeight.w500, 1.4),
  );
}
