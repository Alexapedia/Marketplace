import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/config/theme/maison.dart';
import 'package:placemarket_mobile/config/theme/tokens.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/contrast.dart';

/// Tenant colours a store might pick: defaults, pale, saturated, mid-tone,
/// near-black and near-white.
const _tenants = <(String, String)>[
  ('#071345', '#C9A45C'),
  ('#F5E6B8', '#FFF4D6'),
  ('#E11D48', '#22C55E'),
  ('#808080', '#7A7A7A'),
  ('#0B0B0B', '#3A2A10'),
  ('#FFFFFF', '#FFD400'),
  ('#2563EB', '#F97316'),
];

Color _hex(String h) => Color(int.parse('FF${h.substring(1)}', radix: 16));

const _black = Color(0xFF000000);

void main() {
  group('Maison neutrals', () {
    test('match the spec in light and dark', () {
      final l = Maison.build(brightness: Brightness.light);
      final d = Maison.build(brightness: Brightness.dark);
      expect(l.canvas, const Color(0xFFF7F4EE));
      expect(l.ink, const Color(0xFF16130F));
      expect(l.line, const Color(0xFFE5DED2));
      expect(d.canvas, const Color(0xFF0C0B09));
      expect(d.surface, const Color(0xFF15130F));
      expect(d.ink, const Color(0xFFF5F0E6));
    });

    test('ink and muted ink are >= 4.5:1 on every neutral surface', () {
      for (final b in Brightness.values) {
        final m = Maison.build(brightness: b);
        for (final bg in [m.canvas, m.surface, m.surface2]) {
          expect(contrastRatio(m.ink, bg), greaterThanOrEqualTo(4.5));
          expect(contrastRatio(m.inkMuted, bg), greaterThanOrEqualTo(4.5));
        }
      }
    });
  });

  group('tenant colours', () {
    for (final (p, a) in _tenants) {
      test('primary $p / accent $a stay readable', () {
        for (final b in Brightness.values) {
          final m = Maison.build(
            brightness: b,
            primary: _hex(p),
            accent: _hex(a),
          );
          // On-colours are ink or white (black only for mid-tones where
          // neither reaches AA) and always >= 4.5:1 on their fill.
          for (final (fg, bg) in [
            (m.onPrimary, m.primary),
            (m.onAccent, m.accent),
            (m.onBand, m.band),
          ]) {
            expect(fg, anyOf(Maison.inkLight, Maison.white, _black));
            expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5));
          }
          // Accent text on this mode's surfaces.
          for (final bg in [m.surface, m.canvas, m.surface2]) {
            expect(
              contrastRatio(m.accentInk, bg),
              greaterThanOrEqualTo(4.5),
              reason: '$b accentInk on $bg',
            );
          }
        }
      });
    }

    test('light accent-ink is the accent mixed toward black (oklab 62%)', () {
      final m = Maison.build(brightness: Brightness.light);
      final hsl = HSLColor.fromColor(m.accentInk);
      expect(hsl.lightness, lessThan(HSLColor.fromColor(m.accent).lightness));
      // Hue is preserved within a few degrees.
      expect(
        (hsl.hue - HSLColor.fromColor(m.accent).hue).abs(),
        lessThan(8),
      );
    });

    test('themes expose Maison with computed on-colours', () {
      final c = AppColors.fromJson({'gold': '#FFF4D6', 'primary': '#E11D48'});
      final t = light(c);
      final m = t.extension<Maison>()!;
      expect(t.colorScheme.secondary, m.accent);
      expect(t.colorScheme.onSecondary, m.onAccent);
      expect(t.scaffoldBackgroundColor, m.canvas);
      final dt = dark(
        AppColors.fromJson({'gold': '#3A2A10'}, dark: true),
        brandPrimary: _hex('#0B0B0B'),
      );
      final dm = dt.extension<Maison>()!;
      expect(dt.scaffoldBackgroundColor, const Color(0xFF0C0B09));
      expect(
        contrastRatio(dt.colorScheme.tertiary, dm.surface),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  test('motion tokens', () {
    expect(AppDurations.instant.inMilliseconds, 120);
    expect(AppDurations.fast.inMilliseconds, 200);
    expect(AppDurations.base.inMilliseconds, 320);
    expect(AppDurations.slow.inMilliseconds, 560);
    expect(AppDurations.lavish.inMilliseconds, 900);
    expect(AppCurves.easeOut, const Cubic(0.16, 1, 0.3, 1));
    expect(AppCurves.inOut, const Cubic(0.65, 0, 0.35, 1));
    expect(AppCurves.spring, const Cubic(0.34, 1.56, 0.64, 1));
    expect(AppDurations.staggerFor(0), Duration.zero);
    expect(AppDurations.staggerFor(3).inMilliseconds, 180);
    expect(AppDurations.staggerFor(20), AppDurations.staggerFor(7));
  });
}
