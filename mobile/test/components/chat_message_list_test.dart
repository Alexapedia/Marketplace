import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/models/custom_order_models.dart';
import 'package:placemarket_mobile/modules/pages/chat/view/widgets/chat_message_list.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

List<ChatMessageModel> _msgs(int n) => [
  for (var i = 1; i <= n; i++)
    ChatMessageModel(id: 'id$i', text: 'message $i', isMine: i.isEven),
];

class _Host extends StatefulWidget {
  const _Host({super.key, required this.initial});
  final List<ChatMessageModel> initial;
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<ChatMessageModel> messages = widget.initial;
  void add(ChatMessageModel m) => setState(() => messages = [...messages, m]);
  @override
  Widget build(BuildContext context) => ChatMessageList(messages: messages);
}

Future<GlobalKey<_HostState>> _pump(WidgetTester tester, int n) async {
  tester.view.physicalSize = const Size(390, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey<_HostState>();
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _NoAssets(),
      fallbackLocale: const Locale('en'),
      child: MaterialApp(
        theme: dark(AppColors.darkDefaults),
        home: Scaffold(
          body: _Host(key: key, initial: _msgs(n)),
        ),
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  await tester.pumpAndSettle();
  return key;
}

bool _onScreen(WidgetTester tester, String text) {
  final f = find.text(text);
  if (f.evaluate().isEmpty) return false;
  final r = tester.getRect(f);
  return r.top >= 0 && r.bottom <= 600;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('opens at the latest message', (tester) async {
    await _pump(tester, 40);
    expect(_onScreen(tester, 'message 40'), isTrue);
    expect(_onScreen(tester, 'message 1'), isFalse);
  });

  testWidgets('a new message shows when the reader is at the bottom', (
    tester,
  ) async {
    final host = await _pump(tester, 40);
    host.currentState!.add(
      const ChatMessageModel(id: 'new', text: 'just arrived'),
    );
    await tester.pumpAndSettle();
    expect(_onScreen(tester, 'just arrived'), isTrue);
    expect(find.text('new_messages'), findsNothing);
  });

  testWidgets('reading older messages is not interrupted: a button offers '
      'the new one instead', (tester) async {
    final host = await _pump(tester, 40);
    await tester.drag(find.byType(ListView), const Offset(0, 1500));
    await tester.pumpAndSettle();
    // Any message on screen while reading older ones: it must not move.
    final anchor = [
      for (var i = 1; i <= 40; i++) 'message $i',
    ].firstWhere((t) => _onScreen(tester, t));
    final before = tester.getRect(find.text(anchor));

    host.currentState!.add(
      const ChatMessageModel(id: 'new', text: 'just arrived'),
    );
    await tester.pumpAndSettle();

    expect(_onScreen(tester, 'just arrived'), isFalse);
    expect(find.text('new_messages'), findsOneWidget);
    expect(tester.getRect(find.text(anchor)).top, before.top);

    await tester.tap(find.text('new_messages'));
    await tester.pumpAndSettle();
    expect(_onScreen(tester, 'just arrived'), isTrue);
    expect(find.text('new_messages'), findsNothing);
  });

  testWidgets('sending a message always goes to the bottom', (tester) async {
    final host = await _pump(tester, 40);
    await tester.drag(find.byType(ListView), const Offset(0, 1500));
    await tester.pumpAndSettle();

    host.currentState!.add(
      const ChatMessageModel(id: 'mine', text: 'my reply', isMine: true),
    );
    await tester.pumpAndSettle();

    expect(_onScreen(tester, 'my reply'), isTrue);
    expect(find.text('new_messages'), findsNothing);
  });
}
