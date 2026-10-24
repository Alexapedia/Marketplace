import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/core/components/order_status_timeline.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';

const _flow = [
  'pending',
  'accepted',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'completed',
];

String _label(String s) => const {
  'pending': 'Pending',
  'accepted': 'Accepted',
  'preparing': 'Preparing',
  'ready': 'Ready',
  'out_for_delivery': 'Out for delivery',
  'delivered': 'Delivered',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
}[s]!;

Future<void> _pump(
  WidgetTester tester, {
  required String status,
  List<String> reached = const [],
  double scale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark(AppColors.darkDefaults),
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: OrderStatusTimeline(
            status: status,
            steps: _flow,
            labelOf: _label,
            reached: reached,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('every step is fully visible on a phone, with no sideways '
      'scrolling or cut labels', (tester) async {
    await _pump(tester, status: 'completed');
    expect(find.byType(SingleChildScrollView), findsOneWidget); // the page's
    for (final s in _flow) {
      final text = find.text(_label(s));
      expect(text, findsOneWidget);
      final rect = tester.getRect(text);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the dots line up in one column, whatever the label length', (
    tester,
  ) async {
    await _pump(tester, status: 'out_for_delivery');
    final dots = find.byKey(const ValueKey('timeline-dot'));
    expect(dots, findsNWidgets(_flow.length));
    final centres = {
      for (var i = 0; i < _flow.length; i++) tester.getCenter(dots.at(i)).dx,
    };
    expect(centres, hasLength(1));
  });

  testWidgets('steps before the current one are done, the current one is '
      'marked, later ones are pending', (tester) async {
    await _pump(tester, status: 'ready');
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
    final current = tester.getSemantics(find.text('Ready'));
    expect(current.flagsCollection.isSelected, isTrue);
  });

  testWidgets('a cancelled order shows the steps it reached, then the '
      'cancellation', (tester) async {
    await _pump(
      tester,
      status: 'cancelled',
      reached: const ['pending', 'accepted'],
    );
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    expect(find.text('Preparing'), findsNothing);
  });

  testWidgets('large text does not overflow', (tester) async {
    await _pump(tester, status: 'out_for_delivery', scale: 2);
    expect(tester.takeException(), isNull);
  });
}
