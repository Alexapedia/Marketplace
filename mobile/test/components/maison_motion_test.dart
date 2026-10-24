import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/config/theme/page_transitions.dart';
import 'package:placemarket_mobile/config/theme/tokens.dart';
import 'package:placemarket_mobile/core/components/maison.dart';
import 'package:placemarket_mobile/core/components/skeleton_placeholders.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/view/widgets/bottom_navbar_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget _app(Widget child, {required bool reduce}) => MaterialApp(
  theme: light(AppColors.lightDefaults),
  builder: (context, c) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
    child: c!,
  ),
  home: Scaffold(body: Center(child: child)),
);

const _tabs = [
  NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'a'),
  NavItemData(icon: Icons.grid_view, activeIcon: Icons.grid_view, label: 'b'),
  NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'c'),
];

void main() {
  group('reduced motion collapses Maison motion', () {
    testWidgets('Reveal: staggered entrance only without reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const Reveal(index: 3, child: Text('x')), reduce: true),
      );
      expect(find.byType(Animate), findsNothing);
      await tester.pumpWidget(
        _app(const Reveal(index: 3, child: Text('x')), reduce: false),
      );
      expect(find.byType(Animate), findsOneWidget);
      // Staggered: 3 * 60ms delay, then it settles by `slow`.
      await tester.pump(const Duration(milliseconds: 100));
      final fade = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(Animate),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fade.opacity.value, 0);
      await tester.pump(AppDurations.slow + const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
    });

    test('stagger is 60ms and capped at 8 items', () {
      expect(AppDurations.staggerFor(1).inMilliseconds, 60);
      expect(
        AppDurations.staggerFor(40).inMilliseconds,
        AppDurations.staggerFor(7).inMilliseconds,
      );
    });

    testWidgets('Pressable scales to .97 only without reduced motion', (
      tester,
    ) async {
      double scaleWith(bool reduce) {
        final scale = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.byType(Pressable),
            matching: find.byType(AnimatedScale),
          ),
        );
        return scale.scale;
      }

      for (final reduce in [false, true]) {
        await tester.pumpWidget(
          _app(
            const Pressable(
              haptic: false,
              child: ColoredBox(
                color: Colors.red,
                child: SizedBox(width: 80, height: 80),
              ),
            ),
            reduce: reduce,
          ),
        );
        final g = await tester.startGesture(
          tester.getCenter(find.byType(Pressable)),
        );
        await tester.pump();
        expect(scaleWith(reduce), reduce ? 1.0 : 0.97);
        await g.up();
        await tester.pumpAndSettle();
        expect(scaleWith(reduce), 1.0);
      }
    });

    testWidgets('BumpBadge bumps on change; no bump under reduced motion', (
      tester,
    ) async {
      Widget badge(int n, bool reduce) => _app(
        BumpBadge(count: n, child: const SizedBox(width: 40, height: 40)),
        reduce: reduce,
      );
      await tester.pumpWidget(badge(1, true));
      await tester.pumpWidget(badge(2, true));
      expect(find.byType(Animate), findsNothing);
      expect(find.text('2'), findsOneWidget);

      await tester.pumpWidget(badge(1, false));
      await tester.pumpWidget(badge(2, false));
      expect(find.byType(Animate), findsOneWidget);
      await tester.pump(AppDurations.base);
      await tester.pumpAndSettle();
    });

    testWidgets('AnimatedNumber counts up, or jumps under reduced motion', (
      tester,
    ) async {
      Widget num(double v, bool reduce) => _app(
        AnimatedNumber(value: v, format: (x) => x.round().toString()),
        reduce: reduce,
      );
      await tester.pumpWidget(num(0, true));
      await tester.pumpWidget(num(100, true));
      expect(find.text('100'), findsOneWidget);

      await tester.pumpWidget(num(0, false));
      await tester.pumpWidget(num(100, false));
      await tester.pump(const Duration(milliseconds: 60));
      final mid = int.parse(tester.widget<Text>(find.byType(Text)).data!);
      expect(mid, inInclusiveRange(1, 99));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('bottom nav indicator slides over base, jumps when reduced', (
      tester,
    ) async {
      Duration indicatorDuration() => tester
          .widget<AnimatedPositioned>(
            find.byKey(const ValueKey('nav-indicator')),
          )
          .duration;
      Future<double> pumpNav(bool reduce, int selected) async {
        await tester.pumpWidget(
          _app(
            BottomNavbarItem(
              selectedIndex: selected,
              onTap: (_) {},
              tabs: _tabs,
            ),
            reduce: reduce,
          ),
        );
        return tester
            .getTopLeft(find.byKey(const ValueKey('nav-indicator')))
            .dx;
      }

      await pumpNav(false, 0);
      expect(indicatorDuration(), AppDurations.base);
      final x0 = tester
          .getTopLeft(find.byKey(const ValueKey('nav-indicator')))
          .dx;
      await pumpNav(false, 2);
      await tester.pump(const Duration(milliseconds: 60));
      final xMid = tester
          .getTopLeft(find.byKey(const ValueKey('nav-indicator')))
          .dx;
      await tester.pumpAndSettle();
      final x2 = tester
          .getTopLeft(find.byKey(const ValueKey('nav-indicator')))
          .dx;
      expect(xMid, greaterThan(x0));
      expect(xMid, lessThan(x2));

      await pumpNav(true, 0);
      expect(indicatorDuration(), Duration.zero);
      await pumpNav(true, 2);
      await tester.pump();
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('nav-indicator'))).dx,
        x2,
      );
    });

    testWidgets('skeleton shimmer becomes a static warm fill', (tester) async {
      Future<PaintingEffect?> effect(bool reduce) async {
        await tester.pumpWidget(
          _app(const MaisonSkeleton(child: Text('loading')), reduce: reduce),
        );
        return tester
            .widget<Skeletonizer>(
              find.byWidgetPredicate((w) => w is Skeletonizer),
            )
            .effect;
      }

      expect(await effect(true), isA<SolidColorEffect>());
      // Not reduced: Skeletonizer falls back to the theme's warm shimmer.
      expect(await effect(false), isNull);
      final cfg = light(
        AppColors.lightDefaults,
      ).extension<SkeletonizerConfigData>()!;
      expect(cfg.effect, isA<ShimmerEffect>());
    });

    testWidgets('page transitions: theme uses the Maison builder', (
      tester,
    ) async {
      final theme = light(AppColors.lightDefaults);
      final builders = theme.pageTransitionsTheme.builders;
      expect(
        builders[TargetPlatform.android],
        isA<MaisonPageTransitionsBuilder>(),
      );
      expect(
        const MaisonPageTransitionsBuilder().transitionDuration,
        AppDurations.base,
      );
    });
  });
}
