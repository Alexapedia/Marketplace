import 'package:flutter/material.dart';

import '../utils/functions/color_convert.dart';

class AppColors extends ThemeExtension<AppColors> {
  static const Color blackColor = Color(0xff071345);
  static const Color whiteColor = Colors.white;
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color tertiary;
  final Color backgroundLight;
  final Color backgroundDark;
  final Color surfaceLight;
  final Color surfaceDark;
  final Color surfaceContainerLight;
  final Color surfaceContainerDark;
  final Color cardLight;
  final Color cardDark;
  final Color textPrimaryLight;
  final Color textPrimaryDark;
  final Color textSecondary;
  final Color hint;
  final Color border;
  final Color divider;
  final Color error;
  final Color onError;
  final Color success;
  final Color warning;
  final Color gradientStart;
  final Color gradientEnd;
  final Color onSecondaryContainerLight;
  final Color secondaryContainerDark;
  final Color tertiaryLight;
  final Color onTertiaryLight;
  final Color errorDark;
  final Color onErrorDark;
  final Color borderDark;
  final Color hintDark;
  final Color snackBarBgDark;
  final Color roseSoftLight;
  final Color pinkAccent;
  final Color gold;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.tertiary,
    required this.backgroundLight,
    required this.backgroundDark,
    required this.surfaceLight,
    required this.surfaceDark,
    required this.surfaceContainerLight,
    required this.surfaceContainerDark,
    required this.cardLight,
    required this.cardDark,
    required this.textPrimaryLight,
    required this.textPrimaryDark,
    required this.textSecondary,
    required this.hint,
    required this.border,
    required this.divider,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onSecondaryContainerLight,
    required this.secondaryContainerDark,
    required this.tertiaryLight,
    required this.onTertiaryLight,
    required this.errorDark,
    required this.onErrorDark,
    required this.borderDark,
    required this.hintDark,
    required this.snackBarBgDark,
    required this.roseSoftLight,
    required this.pinkAccent,
    required this.gold,
  });

  static final AppColors lightDefaults = AppColors.fromJson({});
  static final AppColors darkDefaults = AppColors.fromJson({}, dark: true);
  static final AppColors defaults = lightDefaults;

  factory AppColors.fromJson(Map<String, dynamic> json, {bool dark = false}) {
    Color c(String k, String light, String darkHex) =>
        (json[k] ?? (dark ? darkHex : light)).toString().toColor();

    return AppColors(
      primary: c('primary', '#071345', '#FFFFFF'),
      primaryLight: c('primaryLight', '#1A2C72', '#8B9AD4'),
      primaryDark: c('primaryDark', '#050B28', '#071345'),
      primaryContainer: c('primaryContainer', '#E8EBF6', '#1A2B6B'),
      secondary: c('secondary', '#071345', '#FFFFFF'),
      secondaryContainer: c('secondaryContainer', '#E8EBF6', '#C5CEE8'),
      tertiary: c('tertiary', '#3D4F8A', '#8B9AD4'),
      backgroundLight: c('backgroundLight', '#EEF0F6', '#EEF0F6'),
      backgroundDark: c('backgroundDark', '#0E1017', '#0E1017'),
      surfaceLight: c('surfaceLight', '#FFFFFF', '#FFFFFF'),
      surfaceDark: c('surfaceDark', '#12141C', '#12141C'),
      surfaceContainerLight: c('surfaceContainerLight', '#F3F4F9', '#F3F4F9'),
      surfaceContainerDark: c('surfaceContainerDark', '#1B1E29', '#1B1E29'),
      cardLight: c('cardLight', '#FFFFFF', '#FFFFFF'),
      cardDark: c('cardDark', '#1B1E29', '#1B1E29'),
      textPrimaryLight: c('textPrimaryLight', '#071345', '#071345'),
      textPrimaryDark: c('textPrimaryDark', '#ECEEF6', '#ECEEF6'),
      textSecondary: c('textSecondary', '#5B6385', '#9CA2B8'),
      hint: c('hint', '#7A82A6', '#7A82A6'),
      border: c('border', '#E3E6F0', '#E3E6F0'),
      divider: c('divider', '#E3E6F0', '#2A2E3D'),
      error: c('error', '#BA1A1A', '#BA1A1A'),
      onError: c('onError', '#FFFFFF', '#FFFFFF'),
      success: c('success', '#2E7D32', '#2E7D32'),
      warning: c('warning', '#E65100', '#E65100'),
      gradientStart: c('gradientStart', '#071345', '#C9A45C'),
      gradientEnd: c('gradientEnd', '#1C3190', '#C9A45C'),
      onSecondaryContainerLight: c(
        'onSecondaryContainerLight',
        '#071345',
        '#FFFFFF',
      ),
      secondaryContainerDark: c('secondaryContainerDark', '#1A2B6B', '#1A2B6B'),
      tertiaryLight: c('tertiaryLight', '#C5CEE8', '#C5CEE8'),
      onTertiaryLight: c('onTertiaryLight', '#071345', '#071345'),
      errorDark: c('errorDark', '#FFB4AB', '#FFB4AB'),
      onErrorDark: c('onErrorDark', '#690005', '#690005'),
      borderDark: c('borderDark', '#2A2E3D', '#2A2E3D'),
      hintDark: c('hintDark', '#9CA2B8', '#9CA2B8'),
      snackBarBgDark: c('snackBarBgDark', '#1A1D2E', '#1A1D2E'),
      roseSoftLight: c('roseSoftLight', '#FBF6EA', '#2A2518'),
      pinkAccent: c('pinkAccent', '#C9A45C', '#C9A45C'),
      gold: c('gold', '#C9A45C', '#C9A45C'),
    );
  }

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? tertiary,
    Color? backgroundLight,
    Color? backgroundDark,
    Color? surfaceLight,
    Color? surfaceDark,
    Color? surfaceContainerLight,
    Color? surfaceContainerDark,
    Color? cardLight,
    Color? cardDark,
    Color? textPrimaryLight,
    Color? textPrimaryDark,
    Color? textSecondary,
    Color? hint,
    Color? border,
    Color? divider,
    Color? error,
    Color? onError,
    Color? success,
    Color? warning,
    Color? gradientStart,
    Color? gradientEnd,
    Color? onSecondaryContainerLight,
    Color? secondaryContainerDark,
    Color? tertiaryLight,
    Color? onTertiaryLight,
    Color? errorDark,
    Color? onErrorDark,
    Color? borderDark,
    Color? hintDark,
    Color? snackBarBgDark,
    Color? roseSoftLight,
    Color? pinkAccent,
    Color? gold,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      tertiary: tertiary ?? this.tertiary,
      backgroundLight: backgroundLight ?? this.backgroundLight,
      backgroundDark: backgroundDark ?? this.backgroundDark,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      surfaceContainerLight:
          surfaceContainerLight ?? this.surfaceContainerLight,
      surfaceContainerDark: surfaceContainerDark ?? this.surfaceContainerDark,
      cardLight: cardLight ?? this.cardLight,
      cardDark: cardDark ?? this.cardDark,
      textPrimaryLight: textPrimaryLight ?? this.textPrimaryLight,
      textPrimaryDark: textPrimaryDark ?? this.textPrimaryDark,
      textSecondary: textSecondary ?? this.textSecondary,
      hint: hint ?? this.hint,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      onSecondaryContainerLight:
          onSecondaryContainerLight ?? this.onSecondaryContainerLight,
      secondaryContainerDark:
          secondaryContainerDark ?? this.secondaryContainerDark,
      tertiaryLight: tertiaryLight ?? this.tertiaryLight,
      onTertiaryLight: onTertiaryLight ?? this.onTertiaryLight,
      errorDark: errorDark ?? this.errorDark,
      onErrorDark: onErrorDark ?? this.onErrorDark,
      borderDark: borderDark ?? this.borderDark,
      hintDark: hintDark ?? this.hintDark,
      snackBarBgDark: snackBarBgDark ?? this.snackBarBgDark,
      roseSoftLight: roseSoftLight ?? this.roseSoftLight,
      pinkAccent: pinkAccent ?? this.pinkAccent,
      gold: gold ?? this.gold,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: l(primary, other.primary),
      primaryLight: l(primaryLight, other.primaryLight),
      primaryDark: l(primaryDark, other.primaryDark),
      primaryContainer: l(primaryContainer, other.primaryContainer),
      secondary: l(secondary, other.secondary),
      secondaryContainer: l(secondaryContainer, other.secondaryContainer),
      tertiary: l(tertiary, other.tertiary),
      backgroundLight: l(backgroundLight, other.backgroundLight),
      backgroundDark: l(backgroundDark, other.backgroundDark),
      surfaceLight: l(surfaceLight, other.surfaceLight),
      surfaceDark: l(surfaceDark, other.surfaceDark),
      surfaceContainerLight: l(
        surfaceContainerLight,
        other.surfaceContainerLight,
      ),
      surfaceContainerDark: l(surfaceContainerDark, other.surfaceContainerDark),
      cardLight: l(cardLight, other.cardLight),
      cardDark: l(cardDark, other.cardDark),
      textPrimaryLight: l(textPrimaryLight, other.textPrimaryLight),
      textPrimaryDark: l(textPrimaryDark, other.textPrimaryDark),
      textSecondary: l(textSecondary, other.textSecondary),
      hint: l(hint, other.hint),
      border: l(border, other.border),
      divider: l(divider, other.divider),
      error: l(error, other.error),
      onError: l(onError, other.onError),
      success: l(success, other.success),
      warning: l(warning, other.warning),
      gradientStart: l(gradientStart, other.gradientStart),
      gradientEnd: l(gradientEnd, other.gradientEnd),
      onSecondaryContainerLight: l(
        onSecondaryContainerLight,
        other.onSecondaryContainerLight,
      ),
      secondaryContainerDark: l(
        secondaryContainerDark,
        other.secondaryContainerDark,
      ),
      tertiaryLight: l(tertiaryLight, other.tertiaryLight),
      onTertiaryLight: l(onTertiaryLight, other.onTertiaryLight),
      errorDark: l(errorDark, other.errorDark),
      onErrorDark: l(onErrorDark, other.onErrorDark),
      borderDark: l(borderDark, other.borderDark),
      hintDark: l(hintDark, other.hintDark),
      snackBarBgDark: l(snackBarBgDark, other.snackBarBgDark),
      roseSoftLight: l(roseSoftLight, other.roseSoftLight),
      pinkAccent: l(pinkAccent, other.pinkAccent),
      gold: l(gold, other.gold),
    );
  }

  LinearGradient get primaryGradient => LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get brandGradient => const LinearGradient(
    colors: [blackColor, Color(0xFF1C3190)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get onboardingBG => const LinearGradient(
    colors: [blackColor, Color(0xFF0C1A52), Color(0xFF152868)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
  );
}
