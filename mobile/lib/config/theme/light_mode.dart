import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/color_model.dart';

ThemeData light(AppColors c) {
  final base = ColorScheme.light(
    primary: AppColors.blackColor,
    onPrimary: AppColors.whiteColor,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: AppColors.blackColor,
    secondary: AppColors.blackColor,
    onSecondary: AppColors.whiteColor,
    secondaryContainer: c.secondaryContainer,
    onSecondaryContainer: c.onSecondaryContainerLight,
    tertiary: c.tertiary,
    onTertiary: AppColors.whiteColor,
    error: c.error,
    onError: c.onError,
    surface: c.surfaceLight,
    onSurface: c.textPrimaryLight,
    surfaceContainerHighest: c.surfaceContainerLight,
    outline: c.border,
    outlineVariant: c.divider,
    shadow: AppColors.blackColor.withValues(alpha: 0.10),
    scrim: AppColors.blackColor.withValues(alpha: 0.50),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    extensions: {c},
    colorScheme: base,
    scaffoldBackgroundColor: c.backgroundLight,
    dividerColor: c.divider,
    iconTheme: IconThemeData(color: c.textPrimaryLight),
    appBarTheme: AppBarTheme(
      backgroundColor: c.surfaceLight,
      foregroundColor: c.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: c.surfaceLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: c.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: c.textPrimaryLight),
      actionsIconTheme: IconThemeData(color: c.gold),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: c.textPrimaryLight, letterSpacing: -0.5),
      headlineMedium: TextStyle(
        color: c.textPrimaryLight,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: c.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: c.textPrimaryLight,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: c.textPrimaryLight, height: 1.45),
      bodyMedium: TextStyle(color: c.textPrimaryLight, height: 1.4),
      bodySmall: TextStyle(color: c.textSecondary, height: 1.35),
      labelLarge: TextStyle(color: c.primary, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blackColor,
        foregroundColor: AppColors.whiteColor,
        elevation: 4,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primary,
        side: BorderSide(color: c.gold, width: 1.5),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surfaceContainerLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.gold, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: c.cardLight,
      elevation: 2,
      shadowColor: AppColors.blackColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: c.surfaceLight,
      selectedItemColor: AppColors.blackColor,
      unselectedItemColor: c.hint,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceContainerLight,
      selectedColor: c.secondaryContainer,
      labelStyle: TextStyle(color: c.textPrimaryLight, fontSize: 13),
      side: BorderSide(color: c.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.blackColor,
      foregroundColor: AppColors.whiteColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.blackColor,
      contentTextStyle: const TextStyle(color: AppColors.whiteColor),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
