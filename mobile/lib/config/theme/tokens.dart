import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get sheet =>
      const BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

abstract final class AppCurves {
  static const Curve standard = Curves.easeOutCubic;
}
