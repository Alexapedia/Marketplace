import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/contrast.dart';

void main() {
  final l = AppColors.lightDefaults;
  final d = AppColors.darkDefaults;

  test('light goldText on white and background >= 4.5', () {
    expect(contrastRatio(l.goldText, l.surfaceLight), greaterThanOrEqualTo(4.5));
    expect(
      contrastRatio(l.goldText, l.backgroundLight),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('dark gold on surfaceDark >= 4.5', () {
    expect(contrastRatio(d.goldText, d.surfaceDark), greaterThanOrEqualTo(4.5));
  });

  test('inputBorder vs background and fill >= 3.0 (light)', () {
    expect(
      contrastRatio(l.inputBorder, l.backgroundLight),
      greaterThanOrEqualTo(3.0),
    );
    expect(
      contrastRatio(l.inputBorder, l.surfaceLight),
      greaterThanOrEqualTo(3.0),
    );
  });

  test('inputBorder vs surfaces >= 3.0 (dark)', () {
    expect(
      contrastRatio(d.inputBorder, d.surfaceContainerDark),
      greaterThanOrEqualTo(3.0),
    );
  });

  test('hint on surfaceContainerLight >= 4.5', () {
    expect(
      contrastRatio(l.hint, l.surfaceContainerLight),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('warning on white >= 4.5', () {
    expect(contrastRatio(l.warning, Colors.white), greaterThanOrEqualTo(4.5));
  });

  test('ensureContrast(#F5E6B8 on white) >= 4.5', () {
    final out = ensureContrast(const Color(0xFFF5E6B8), Colors.white);
    expect(contrastRatio(out, Colors.white), greaterThanOrEqualTo(4.5));
  });

  test('tenant gold override recomputes goldText with contrast', () {
    final c = AppColors.fromJson({'gold': '#F5E6B8'});
    expect(contrastRatio(c.goldText, c.surfaceLight), greaterThanOrEqualTo(4.5));
  });

  // Maison: the focus ring is the accent ("the light"), as accent-ink so it
  // keeps >= 3:1 against the field fill.
  test('theme focusedBorder is accent-ink and visible on the field', () {
    for (final t in [light(l), dark(d)]) {
      final b = t.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(b.borderSide.color, t.colorScheme.tertiary);
      expect(b.borderSide.width, 2);
      expect(
        contrastRatio(b.borderSide.color, t.inputDecorationTheme.fillColor!),
        greaterThanOrEqualTo(3.0),
      );
    }
  });

  test('errorBorder exists', () {
    for (final t in [light(l), dark(d)]) {
      expect(t.inputDecorationTheme.errorBorder, isNotNull);
      expect(t.inputDecorationTheme.focusedErrorBorder, isNotNull);
    }
  });

  test('dark goldText stays readable when a tenant sets a dark accent', () {
    final c = AppColors.fromJson({'gold': '#3A2A10'}, dark: true);
    expect(contrastRatio(c.goldText, c.surfaceDark), greaterThanOrEqualTo(4.5));
  });
}
