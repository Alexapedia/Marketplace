import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/color_model.dart';
import 'tokens.dart';
import 'typography.dart';

ThemeData dark(AppColors c) {
  final base = ColorScheme.dark(
    primary: AppColors.whiteColor,
    onPrimary: AppColors.blackColor,
    primaryContainer: c.surfaceContainerDark,
    onPrimaryContainer: AppColors.whiteColor,
    secondary: AppColors.whiteColor,
    onSecondary: AppColors.blackColor,
    secondaryContainer: c.secondaryContainerDark,
    onSecondaryContainer: c.secondaryContainer,
    tertiary: c.tertiaryLight,
    onTertiary: c.onTertiaryLight,
    error: c.errorDark,
    onError: c.onErrorDark,
    surface: c.surfaceDark,
    onSurface: c.textPrimaryDark,
    surfaceContainerHighest: c.surfaceContainerDark,
    inverseSurface: AppColors.blackColor,
    onInverseSurface: AppColors.whiteColor,
    outline: c.hintDark,
    outlineVariant: c.borderDark,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: kFontFamily,
    extensions: {c},
    colorScheme: base,
    scaffoldBackgroundColor: c.backgroundDark,
    dividerColor: c.borderDark,
    iconTheme: IconThemeData(color: c.textPrimaryDark),
    appBarTheme: AppBarTheme(
      backgroundColor: c.surfaceDark,
      foregroundColor: c.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: c.surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: kFontFamily,
        color: c.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: c.textPrimaryDark),
      actionsIconTheme: IconThemeData(color: c.gold),
    ),
    textTheme: buildTextTheme(
      onSurface: c.textPrimaryDark,
      secondary: c.textSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.gold,
        foregroundColor: c.backgroundDark,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: c.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surfaceDark,
      selectedItemColor: c.gold,
      unselectedItemColor: c.hintDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerDark,
      border: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: c.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: c.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: base.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: base.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: base.error, width: 2),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.whiteColor,
      foregroundColor: AppColors.blackColor,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.whiteColor,
        side: const BorderSide(color: AppColors.whiteColor, width: 1.5),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.snackBarBgDark,
      contentTextStyle: const TextStyle(color: AppColors.whiteColor),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
