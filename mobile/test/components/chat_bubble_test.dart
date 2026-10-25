import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/models/custom_order_models.dart';
import 'package:placemarket_mobile/modules/pages/chat/view/widgets/chat_bubble.dart';

Future<void> _pump(WidgetTester tester, ChatMessageModel m) =>
    tester.pumpWidget(
      MaterialApp(
        theme: dark(AppColors.darkDefaults),
        home: Scaffold(body: ChatBubble(message: m)),
      ),
    );

void main() {
  testWidgets('a message without a timestamp still renders', (tester) async {
    await _pump(tester, const ChatMessageModel(id: '1', text: 'hello'));
    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('a message with a timestamp shows its time', (tester) async {
    await _pump(
      tester,
      ChatMessageModel(
        id: '1',
        text: 'hello',
        createdAt: DateTime(2026, 1, 2, 9, 5),
      ),
    );
    expect(find.text('09:05'), findsOneWidget);
  });
}
