import 'package:flutter/material.dart';

/// WCAG contrast ratio between two opaque colors (1.0 - 21.0).
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

/// Adjusts [fg] lightness until it reaches [min] contrast against [bg].
/// Darkens when [bg] is light, lightens when [bg] is dark.
Color ensureContrast(Color fg, Color bg, {double min = 4.5}) {
  if (contrastRatio(fg, bg) >= min) return fg;
  final hsl = HSLColor.fromColor(fg);
  final darken = bg.computeLuminance() > 0.5;
  var lightness = hsl.lightness;
  var out = fg;
  for (var i = 0; i < 100; i++) {
    lightness = (lightness + (darken ? -0.01 : 0.01)).clamp(0.0, 1.0);
    out = hsl.withLightness(lightness).toColor();
    if (contrastRatio(out, bg) >= min || lightness <= 0 || lightness >= 1) {
      break;
    }
  }
  return out;
}
