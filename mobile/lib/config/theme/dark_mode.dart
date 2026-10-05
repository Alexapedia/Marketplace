import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/color_model.dart';

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
    outline: c.hintDark,
    outlineVariant: c.borderDark,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
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
        color: c.textPrimaryDark,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: c.textPrimaryDark),
      actionsIconTheme: IconThemeData(color: c.gold),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: c.textPrimaryDark, letterSpacing: -0.5),
      headlineMedium: TextStyle(
        color: c.textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(color: c.textPrimaryDark, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: c.textPrimaryDark, height: 1.45),
      bodyMedium: TextStyle(color: c.textPrimaryDark, height: 1.4),
      bodySmall: TextStyle(color: c.textSecondary, height: 1.35),
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.gold, width: 2),
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
