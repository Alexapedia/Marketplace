import 'package:flutter/material.dart';

import '../utils/functions/color_convert.dart';

class AppColors extends ThemeExtension<AppColors> {
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

  static final AppColors defaults = AppColors.fromJson({});

  factory AppColors.fromJson(Map<String, dynamic> json) {
    Color c(String k, String f) => (json[k] ?? f).toString().toColor();

    return AppColors(
      primary: c('primary', '#1C1A17'),
      primaryLight: c('primaryLight', '#3A3630'),
      primaryDark: c('primaryDark', '#0E0D0B'),
      primaryContainer: c('primaryContainer', '#EFE8DC'),
      secondary: c('secondary', '#C6A667'),
      secondaryContainer: c('secondaryContainer', '#F3E8D0'),
      tertiary: c('tertiary', '#8A7354'),
      backgroundLight: c('backgroundLight', '#F7F4EF'),
      backgroundDark: c('backgroundDark', '#121212'),
      surfaceLight: c('surfaceLight', '#FFFcf7'),
      surfaceDark: c('surfaceDark', '#1C1C1C'),
      surfaceContainerLight: c('surfaceContainerLight', '#EFEBE3'),
      surfaceContainerDark: c('surfaceContainerDark', '#2A2A2A'),
      cardLight: c('cardLight', '#FFFFFF'),
      cardDark: c('cardDark', '#1E1E1E'),
      textPrimaryLight: c('textPrimaryLight', '#1C1A17'),
      textPrimaryDark: c('textPrimaryDark', '#F7F4EF'),
      textSecondary: c('textSecondary', '#6B645C'),
      hint: c('hint', '#9A9288'),
      border: c('border', '#E4DDD2'),
      divider: c('divider', '#EDE7DC'),
      error: c('error', '#BA1A1A'),
      onError: c('onError', '#FFFFFF'),
      success: c('success', '#2E7D32'),
      warning: c('warning', '#E65100'),
      gradientStart: c('gradientStart', '#1C1A17'),
      gradientEnd: c('gradientEnd', '#C6A667'),
      onSecondaryContainerLight: c('onSecondaryContainerLight', '#3E2E10'),
      secondaryContainerDark: c('secondaryContainerDark', '#5D4A22'),
      tertiaryLight: c('tertiaryLight', '#E2C992'),
      onTertiaryLight: c('onTertiaryLight', '#3A2C14'),
      errorDark: c('errorDark', '#FFB4AB'),
      onErrorDark: c('onErrorDark', '#690005'),
      borderDark: c('borderDark', '#3A3A3A'),
      hintDark: c('hintDark', '#A39A90'),
      snackBarBgDark: c('snackBarBgDark', '#2A241C'),
      roseSoftLight: c('roseSoftLight', '#F7F4EF'),
      pinkAccent: c('pinkAccent', '#C6A667'),
      gold: c('gold', '#C6A667'),
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

  LinearGradient get onboardingBG => LinearGradient(
    colors: [
      textPrimaryLight,
      primaryDark,
      primary,
      Color(0xFF2A241C),
      backgroundDark,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
  );
}
