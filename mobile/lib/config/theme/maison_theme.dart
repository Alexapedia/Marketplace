import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/color_model.dart';
import 'maison.dart';
import 'page_transitions.dart';
import 'tokens.dart';
import 'typography.dart';

/// One Maison [ThemeData] for either brightness. [c] keeps the legacy
/// [AppColors] extension available to widgets that still read it.
ThemeData maisonTheme(AppColors c, Maison m) {
  final dark = m.isDark;
  final scheme = ColorScheme(
    brightness: m.brightness,
    // Light: the brand primary leads (focus-free UI accents, switches,
    // links). Dark: the accent is "the light" of the room.
    primary: dark ? m.accent : m.primary,
    onPrimary: dark ? m.onAccent : m.onPrimary,
    primaryContainer: m.primarySoft,
    onPrimaryContainer: m.ink,
    secondary: m.accent,
    onSecondary: m.onAccent,
    secondaryContainer: m.accentSoft,
    onSecondaryContainer: m.ink,
    tertiary: m.accentInk,
    onTertiary: Maison.onColor(m.accentInk),
    error: m.danger,
    onError: Maison.onColor(m.danger),
    errorContainer: Color.alphaBlend(m.danger.withValues(alpha: 0.12), m.surface),
    onErrorContainer: m.ink,
    surface: m.surface,
    onSurface: m.ink,
    onSurfaceVariant: m.inkMuted,
    surfaceContainerLowest: dark ? m.canvas : m.surface,
    surfaceContainerLow: Color.lerp(m.surface, m.surface2, 0.35)!,
    surfaceContainer: Color.lerp(m.surface, m.surface2, 0.6)!,
    surfaceContainerHigh: m.surface2,
    surfaceContainerHighest: Color.lerp(m.surface2, m.line, 0.4)!,
    surfaceTint: Colors.transparent,
    outline: c.inputBorder,
    outlineVariant: m.line,
    shadow: const Color(0xFF16130F),
    scrim: Colors.black,
    inverseSurface: dark ? const Color(0xFFF5F0E6) : const Color(0xFF16130F),
    onInverseSurface: dark ? const Color(0xFF16130F) : const Color(0xFFF5F0E6),
    inversePrimary: m.accent,
  );

  final text = buildTextTheme(onSurface: m.ink, secondary: m.inkMuted);
  final focus = m.accentInk;
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: AppRadius.input,
        borderSide: BorderSide(color: color, width: width),
      );
  final pillShape = RoundedRectangleBorder(borderRadius: AppRadius.button);
  const buttonSize = Size(64, 52);
  final buttonText = text.labelLarge!.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: m.brightness,
    fontFamily: kFontFamily,
    extensions: {c, m},
    colorScheme: scheme,
    scaffoldBackgroundColor: m.canvas,
    canvasColor: m.canvas,
    dividerColor: m.line,
    splashFactory: InkSparkle.splashFactory,
    highlightColor: m.ink.withValues(alpha: 0.04),
    splashColor: m.accent.withValues(alpha: 0.12),
    hoverColor: m.ink.withValues(alpha: 0.04),
    focusColor: m.accent.withValues(alpha: 0.18),
    iconTheme: IconThemeData(color: m.ink, size: 22),
    textTheme: text,
    dividerTheme: DividerThemeData(color: m.line, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: m.canvas,
      surfaceTintColor: Colors.transparent,
      foregroundColor: m.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: m.brightness,
        systemNavigationBarColor: m.canvas,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: displayStyle(size: 20, color: m.ink),
      iconTheme: IconThemeData(color: m.ink),
      actionsIconTheme: IconThemeData(color: m.ink),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: m.accent,
        foregroundColor: m.onAccent,
        disabledBackgroundColor: m.surface2,
        disabledForegroundColor: m.inkMuted,
        elevation: 0,
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: pillShape,
        textStyle: buttonText,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: m.accent,
        foregroundColor: m.onAccent,
        disabledBackgroundColor: m.surface2,
        disabledForegroundColor: m.inkMuted,
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: pillShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: m.ink,
        side: BorderSide(color: c.inputBorder),
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        shape: pillShape,
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: m.accentInk,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge,
        shape: pillShape,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: m.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: m.surface,
      hintStyle: text.bodyMedium!.copyWith(color: m.inkMuted),
      labelStyle: text.bodyMedium!.copyWith(color: m.inkMuted),
      floatingLabelStyle: text.bodyMedium!.copyWith(color: focus),
      prefixIconColor: m.inkMuted,
      suffixIconColor: m.inkMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: border(c.inputBorder),
      enabledBorder: border(c.inputBorder),
      focusedBorder: border(focus, 2),
      errorBorder: border(m.danger),
      focusedErrorBorder: border(m.danger, 2),
    ),
    cardTheme: CardThemeData(
      color: m.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl - 4),
        side: BorderSide(color: m.line),
      ),
      margin: EdgeInsets.zero,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: m.inkMuted,
      textColor: m.ink,
      minVerticalPadding: 12,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: m.glass,
      selectedItemColor: m.accentInk,
      unselectedItemColor: m.inkMuted,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: m.surface,
      indicatorColor: m.accentSoft,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: m.surface,
      selectedColor: m.accent,
      secondarySelectedColor: m.accent,
      checkmarkColor: m.onAccent,
      labelStyle: text.labelLarge!.copyWith(color: m.ink),
      secondaryLabelStyle: text.labelLarge!.copyWith(color: m.onAccent),
      side: BorderSide(color: m.line),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? m.accent : null,
      ),
      checkColor: WidgetStatePropertyAll(m.onAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? m.accentInk : m.inkMuted,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? m.onAccent : m.inkMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? m.accent : m.surface2,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? m.accent : c.inputBorder,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: m.accentInk,
      linearTrackColor: m.surface2,
      circularTrackColor: Colors.transparent,
      refreshBackgroundColor: m.surface,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: m.ink,
      unselectedLabelColor: m.inkMuted,
      labelStyle: text.labelLarge,
      unselectedLabelStyle: text.labelLarge!.copyWith(
        fontWeight: FontWeight.w500,
      ),
      indicatorColor: m.accent,
      dividerColor: m.line,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: m.accent,
      foregroundColor: m.onAccent,
      elevation: 2,
      highlightElevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: m.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: m.surface,
      showDragHandle: true,
      dragHandleColor: m.line,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: m.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: m.line),
      ),
      titleTextStyle: displayStyle(size: 22, color: m.ink),
      contentTextStyle: text.bodyMedium!.copyWith(color: m.inkMuted),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? m.surface2 : const Color(0xFF16130F),
      contentTextStyle: text.bodyMedium!.copyWith(
        color: const Color(0xFFF5F0E6),
      ),
      actionTextColor: m.accent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: dark ? BorderSide(color: m.line) : BorderSide.none,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF16130F).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      textStyle: text.labelMedium!.copyWith(color: const Color(0xFFF5F0E6)),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: m.accent,
      textColor: m.onAccent,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: MaisonPageTransitionsBuilder(),
        // iOS keeps the native slide so the edge swipe-back gesture works.
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: MaisonPageTransitionsBuilder(),
        TargetPlatform.fuchsia: MaisonPageTransitionsBuilder(),
        TargetPlatform.linux: MaisonPageTransitionsBuilder(),
        TargetPlatform.windows: MaisonPageTransitionsBuilder(),
      },
    ),
  );
}
