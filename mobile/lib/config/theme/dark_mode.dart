import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/color_model.dart';

ThemeData dark(AppColors c) {
  final base = ColorScheme.dark(
    primary: c.gold,
    onPrimary: c.primaryDark,
    primaryContainer: c.primaryDark,
    onPrimaryContainer: c.primaryContainer,
    secondary: c.secondary,
    onSecondary: c.primaryDark,
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
      bodyLarge: TextStyle(color: c.textPrimaryDark),
      bodyMedium: TextStyle(color: c.textSecondary),
      bodySmall: TextStyle(color: c.hintDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: c.gold,
        foregroundColor: c.primaryDark,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: c.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      backgroundColor: c.gold,
      foregroundColor: c.primaryDark,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.snackBarBgDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
