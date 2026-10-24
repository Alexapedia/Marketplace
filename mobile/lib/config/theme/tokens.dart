import 'package:flutter/material.dart';

/// Maison spacing scale: 4, 8, 12, 16, 24, 32, 48, 64, 96.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double huge = 96;
}

/// Maison radius scale: 8 / 12 / 16 / 24 / 32 / pill.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get panel => BorderRadius.circular(xl);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(pill);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xxl));
}

/// Maison motion durations ("concierge motion").
abstract final class AppDurations {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 560);
  static const Duration lavish = Duration(milliseconds: 900);

  /// Delay between staggered entrance items; only the first [staggerMax]
  /// items are staggered, the rest arrive with the last one.
  static const Duration stagger = Duration(milliseconds: 60);
  static const int staggerMax = 8;

  static Duration staggerFor(int index) =>
      stagger * (index < staggerMax ? index : staggerMax - 1);
}

abstract final class AppCurves {
  /// cubic-bezier(.16, 1, .3, 1) — expo-out, the default.
  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);

  /// cubic-bezier(.65, 0, .35, 1).
  static const Curve inOut = Cubic(0.65, 0, 0.35, 1);

  /// cubic-bezier(.34, 1.56, .64, 1) — badges only.
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);

  static const Curve standard = easeOut;
}

/// Maison depth. Shadow-1 at rest, shadow-2 for lifted surfaces.
abstract final class AppShadows {
  static const Color _ink = Color(0xFF16130F);

  static List<BoxShadow> one(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 30,
            spreadRadius: -14,
            offset: Offset(0, 10),
          ),
        ]
      : [
          BoxShadow(
            color: _ink.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: _ink.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -12,
            offset: const Offset(0, 8),
          ),
        ];

  static List<BoxShadow> two(Brightness b) => [
    BoxShadow(
      color: b == Brightness.dark
          ? const Color(0xBF000000)
          : _ink.withValues(alpha: 0.35),
      blurRadius: 56,
      spreadRadius: -28,
      offset: const Offset(0, 28),
    ),
  ];

  /// Soft upward shadow for sticky bottom chrome.
  static List<BoxShadow> up(Brightness b) => [
    BoxShadow(
      color: b == Brightness.dark
          ? const Color(0x80000000)
          : _ink.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, -6),
    ),
  ];
}
