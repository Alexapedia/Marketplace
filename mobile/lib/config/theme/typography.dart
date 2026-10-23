import 'package:flutter/material.dart';

/// Body / UI family (covers Latin and Arabic).
const String kFontFamily = 'IBMPlexSansArabic';

/// Display family: Playfair Display renders Latin, El Messiri renders Arabic.
const String kDisplayFamily = 'PlayfairDisplay';
const String kDisplayArabicFamily = 'ElMessiri';
const List<String> kDisplayFallback = [kDisplayArabicFamily, kFontFamily];

/// Both display fonts ship as variable fonts (the official google/fonts
/// files), so the weight is applied through the `wght` axis as well as
/// [FontWeight] — otherwise the engine renders the default instance.
TextStyle displayStyle({
  required double size,
  FontWeight weight = FontWeight.w600,
  double height = 1.15,
  Color? color,
  double? letterSpacing,
}) => TextStyle(
  fontFamily: kDisplayFamily,
  fontFamilyFallback: kDisplayFallback,
  fontSize: size,
  fontWeight: weight,
  fontVariations: [FontVariation.weight(weight.value.toDouble())],
  height: height,
  // No tracking: Arabic glyphs fall back into the same run.
  letterSpacing: letterSpacing ?? 0,
  color: color,
);

extension MaisonTextStyle on TextStyle {
  /// Switches any style to the display family, keeping size and colour.
  TextStyle get display => copyWith(
    fontFamily: kDisplayFamily,
    fontFamilyFallback: kDisplayFallback,
    fontVariations: [
      FontVariation.weight((fontWeight ?? FontWeight.w600).value.toDouble()),
    ],
  );

  /// Sets weight on both the static and the variable (`wght`) axis.
  TextStyle weight(FontWeight w) => copyWith(
    fontWeight: w,
    fontVariations: fontFamily == kDisplayFamily
        ? [FontVariation.weight(w.value.toDouble())]
        : fontVariations,
  );

  /// Tabular figures for prices and counts.
  TextStyle get tabular =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
}

/// Maison type scale (sp): 12, 14, 16 (body), 18, 22, 28, 36, 48.
/// Display tiers + headline + titleLarge use the display family; the rest
/// are IBM Plex Sans Arabic. Line height 1.6 body, 1.15 display.
TextTheme buildTextTheme({required Color onSurface, required Color secondary}) {
  TextStyle s(double size, FontWeight w, double height, [Color? color]) =>
      TextStyle(
        fontFamily: kFontFamily,
        fontSize: size,
        fontWeight: w,
        height: height,
        color: color ?? onSurface,
      );
  TextStyle d(double size, [FontWeight w = FontWeight.w600]) =>
      displayStyle(size: size, weight: w, color: onSurface);

  return TextTheme(
    displayLarge: d(48),
    displayMedium: d(36),
    displaySmall: d(28),
    headlineLarge: d(28),
    headlineMedium: d(22),
    headlineSmall: d(20),
    titleLarge: d(22),
    titleMedium: s(16, FontWeight.w600, 1.35),
    titleSmall: s(14, FontWeight.w600, 1.35),
    bodyLarge: s(16, FontWeight.w400, 1.6),
    bodyMedium: s(14, FontWeight.w400, 1.6),
    bodySmall: s(12, FontWeight.w400, 1.5, secondary),
    labelLarge: s(14, FontWeight.w600, 1.4),
    labelMedium: s(12, FontWeight.w600, 1.4),
    labelSmall: s(12, FontWeight.w500, 1.4),
  );
}
