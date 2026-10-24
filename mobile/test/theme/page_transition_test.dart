import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/page_transitions.dart';
import 'package:placemarket_mobile/config/theme/tokens.dart';

Widget _app({required bool reduce}) => MaterialApp(
  theme: ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: MaisonPageTransitionsBuilder(),
        TargetPlatform.iOS: MaisonPageTransitionsBuilder(),
      },
    ),
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: child!,
  ),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('next', key: Key('next'))),
          ),
        ),
        child: const Text('go'),
      ),
    ),
  ),
);

double _dy(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const Key('next'))).dy;

void main() {
  testWidgets('routes fade in while rising 16px over the base duration', (
    tester,
  ) async {
    await tester.pumpWidget(_app(reduce: false));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final start = _dy(tester);
    final transforms = find.ancestor(
      of: find.byKey(const Key('next')),
      matching: find.byType(Transform),
    );
    expect(transforms, findsWidgets);
    await tester.pumpAndSettle();
    final end = _dy(tester);
    expect(start - end, greaterThan(0));
    expect(start - end, lessThanOrEqualTo(MaisonPageTransitionsBuilder.rise));
    expect(
      const MaisonPageTransitionsBuilder().transitionDuration,
      AppDurations.base,
    );
  });

  testWidgets('reduced motion leaves only a short cross-fade, no movement', (
    tester,
  ) async {
    await tester.pumpWidget(_app(reduce: true));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final start = _dy(tester);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byKey(const Key('next')),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, greaterThan(0));
    // Fully opaque by `fast` (200ms) even though the route runs `base`.
    await tester.pump(AppDurations.fast - const Duration(milliseconds: 40));
    expect(fade.opacity.value, 1);
    await tester.pumpAndSettle();
    expect(_dy(tester), start);
  });
}
