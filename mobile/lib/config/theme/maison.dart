import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/functions/contrast.dart';

/// Maison palette: fixed warm-stone neutrals plus the tenant's brand colours
/// with computed, contrast-safe companions. Read it with `context.maison`.
class Maison extends ThemeExtension<Maison> {
  const Maison({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.danger,
    required this.success,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.accentInk,
    required this.accentSoft,
    required this.primarySoft,
    required this.band,
    required this.onBand,
  });

  static const Color defaultPrimary = Color(0xFF071345);
  static const Color defaultAccent = Color(0xFFC9A45C);
  static const Color inkLight = Color(0xFF16130F);
  static const Color white = Color(0xFFFFFFFF);

  final Brightness brightness;
  final Color canvas;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color ink;
  final Color inkMuted;
  final Color danger;
  final Color success;

  /// Tenant brand primary ("the deep brand band").
  final Color primary;
  final Color onPrimary;

  /// Tenant accent ("the light"): CTAs, prices, active indicators, rules.
  final Color accent;
  final Color onAccent;

  /// Accent usable as text on this mode's surfaces (>= 4.5:1).
  final Color accentInk;
  final Color accentSoft;
  final Color primarySoft;

  /// Hero / header band fill and its text colour.
  final Color band;
  final Color onBand;

  bool get isDark => brightness == Brightness.dark;

  /// Glass chrome fill (surface at 72%).
  Color get glass => surface.withValues(alpha: 0.72);

  /// Dark cards get a 1px top highlight.
  Color get highlight =>
      isDark ? const Color(0x0AFFFFFF) : const Color(0x00FFFFFF);

  /// 1px gold rule: accent fading to transparent along the reading direction.
  LinearGradient rule(TextDirection dir) => LinearGradient(
    begin: AlignmentDirectional.centerStart.resolve(dir),
    end: AlignmentDirectional.centerEnd.resolve(dir),
    colors: [accent, accent.withValues(alpha: 0)],
  );

  /// Ink or white, whichever reads better on [bg]. For the narrow band of
  /// mid-tones where neither reaches 4.5:1, pure black does (>= 4.58:1).
  static Color onColor(Color bg) {
    final ink = contrastRatio(inkLight, bg);
    final wh = contrastRatio(white, bg);
    if (ink < 4.5 && wh < 4.5) return const Color(0xFF000000);
    return ink >= wh ? inkLight : white;
  }

  factory Maison.build({
    required Brightness brightness,
    Color? primary,
    Color? accent,
  }) {
    final p = primary ?? defaultPrimary;
    final a = accent ?? defaultAccent;
    if (brightness == Brightness.dark) {
      const surface = Color(0xFF15130F);
      const canvas = Color(0xFF0C0B09);
      final band = Color.lerp(p, canvas, 0.35)!;
      return Maison(
        brightness: brightness,
        canvas: canvas,
        surface: surface,
        surface2: const Color(0xFF1E1B16),
        line: const Color(0xFF2C2821),
        ink: const Color(0xFFF5F0E6),
        inkMuted: const Color(0xFFA79F92),
        danger: const Color(0xFFF07178),
        success: const Color(0xFF7BC8A0),
        primary: p,
        onPrimary: onColor(p),
        accent: a,
        onAccent: onColor(a),
        accentInk: ensureContrast(
          ensureContrast(a, surface),
          const Color(0xFF1E1B16),
        ),
        accentSoft: Color.alphaBlend(a.withValues(alpha: 0.16), surface),
        primarySoft: Color.alphaBlend(p.withValues(alpha: 0.22), surface),
        band: band,
        onBand: onColor(band),
      );
    }
    const surface = Color(0xFFFFFFFF);
    const canvas = Color(0xFFF7F4EE);
    const surface2 = Color(0xFFF1ECE3);
    // Spec: color-mix(in oklab, accent 62%, black), then guaranteed 4.5:1 on
    // every light neutral it may sit on.
    var ink = mixOklab(a, const Color(0xFF000000), 0.62);
    for (final bg in const [surface, canvas, surface2]) {
      ink = ensureContrast(ink, bg);
    }
    return Maison(
      brightness: brightness,
      canvas: canvas,
      surface: surface,
      surface2: surface2,
      line: const Color(0xFFE5DED2),
      ink: inkLight,
      inkMuted: const Color(0xFF5E574D),
      danger: const Color(0xFFB4232F),
      success: const Color(0xFF2F6B4F),
      primary: p,
      onPrimary: onColor(p),
      accent: a,
      onAccent: onColor(a),
      accentInk: ink,
      accentSoft: Color.alphaBlend(a.withValues(alpha: 0.14), surface),
      primarySoft: Color.alphaBlend(p.withValues(alpha: 0.08), surface),
      band: p,
      onBand: onColor(p),
    );
  }

  @override
  Maison copyWith() => this;

  @override
  Maison lerp(ThemeExtension<Maison>? other, double t) {
    if (other is! Maison) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Maison(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      inkMuted: l(inkMuted, other.inkMuted),
      danger: l(danger, other.danger),
      success: l(success, other.success),
      primary: l(primary, other.primary),
      onPrimary: t < 0.5 ? onPrimary : other.onPrimary,
      accent: l(accent, other.accent),
      onAccent: t < 0.5 ? onAccent : other.onAccent,
      accentInk: l(accentInk, other.accentInk),
      accentSoft: l(accentSoft, other.accentSoft),
      primarySoft: l(primarySoft, other.primarySoft),
      band: l(band, other.band),
      onBand: t < 0.5 ? onBand : other.onBand,
    );
  }
}

extension MaisonContext on BuildContext {
  Maison get maison =>
      Theme.of(this).extension<Maison>() ??
      Maison.build(brightness: Theme.of(this).brightness);
}

/// `color-mix(in oklab, a [t], b)`.
Color mixOklab(Color a, Color b, double t) {
  final x = _toOklab(a);
  final y = _toOklab(b);
  final m = [
    for (var i = 0; i < 3; i++) x[i] * t + y[i] * (1 - t),
  ];
  return _fromOklab(m, a.a * t + b.a * (1 - t));
}

double _lin(double c) =>
    c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double _gam(double c) {
  final v = c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4) - 0.055;
  return v.clamp(0.0, 1.0);
}

double _cbrt(double v) =>
    v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();

List<double> _toOklab(Color c) {
  final r = _lin(c.r), g = _lin(c.g), b = _lin(c.b);
  final l = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
  final m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
  final s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
  return [
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  ];
}

Color _fromOklab(List<double> lab, double alpha) {
  final l = math.pow(lab[0] + 0.3963377774 * lab[1] + 0.2158037573 * lab[2], 3);
  final m = math.pow(lab[0] - 0.1055613458 * lab[1] - 0.0638541728 * lab[2], 3);
  final s = math.pow(lab[0] - 0.0894841775 * lab[1] - 1.2914855480 * lab[2], 3);
  final r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
  final g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
  final b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;
  return Color.from(alpha: alpha, red: _gam(r), green: _gam(g), blue: _gam(b));
}
