import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/app_button.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) {
  final app = MaterialApp(
    theme: light(AppColors.lightDefaults),
    home: screenUtilHandler(child: Scaffold(body: Center(child: child))),
  );
  if (!disableAnimations) return app;
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: app,
  );
}

void main() {
  testWidgets('tap calls onTap exactly once', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _wrap(AppButton(title: 'Go', onTap: () => taps++)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets(
      'onTap null renders disabled colors and Semantics(enabled:false, button:true)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const AppButton(title: 'Go', onTap: null)));
    await tester.pumpAndSettle();
    final scheme = Theme.of(tester.element(find.byType(AppButton))).colorScheme;
    final container = tester.widget<Container>(find
        .descendant(
            of: find.byType(AppButton), matching: find.byType(Container))
        .first);
    final deco = container.decoration as BoxDecoration;
    expect(deco.color, scheme.surfaceContainerHighest);
    expect(deco.gradient, isNull);
    expect(deco.boxShadow, isNull);
    final text = tester.widget<Text>(find.text('Go'));
    expect(text.style!.color, scheme.onSurface.withValues(alpha: 0.38));
    final node = tester.getSemantics(find.bySemanticsLabel("Go"));
    final data = node.getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.flagsCollection.hasEnabledState, isTrue);
    expect(data.flagsCollection.isEnabled, isFalse);
    handle.dispose();
  });

  testWidgets('isLoading shows a progress indicator, ignores taps, keeps size',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _wrap(AppButton(title: 'Go', onTap: () => taps++)));
    await tester.pumpAndSettle();
    final normal = tester.getSize(find.byType(AppButton));

    await tester.pumpWidget(
        _wrap(AppButton(title: 'Go', isLoading: true, onTap: () => taps++)));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Go'), findsNothing);
    await tester.tap(find.byType(AppButton));
    await tester.pump(const Duration(milliseconds: 500));
    expect(taps, 0);
    expect(tester.getSize(find.byType(AppButton)), normal);
  });

  testWidgets('no fade-in when disableAnimations is true', (tester) async {
    await tester.pumpWidget(_wrap(
        AppButton(title: 'Go', onTap: () {}),
        disableAnimations: true));
    expect(find.byType(Animate), findsNothing);
  });
}
