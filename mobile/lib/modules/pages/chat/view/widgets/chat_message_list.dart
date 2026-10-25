import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/models/custom_order_models.dart';
import '../../../../../core/utils/functions/motion.dart';
import 'chat_bubble.dart';

/// Messages, newest at the bottom. A reversed list opens at the latest
/// message and keeps it in view when the keyboard opens. New messages are
/// followed when the reader is at the bottom (or sent them); while they read
/// older ones, new messages wait behind a "new messages" button so the view
/// does not jump.
class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key, required this.messages});

  final List<ChatMessageModel> messages;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  /// Within this distance of the newest message counts as "at the bottom".
  static const double _nearBottom = 48;

  final _scroll = ScrollController();
  late int _shown = widget.messages.length;

  bool get _atBottom => !_scroll.hasClients || _scroll.offset <= _nearBottom;
  int get _pending => widget.messages.length - _shown;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_pending > 0 && _atBottom) setState(_showAll);
    });
  }

  @override
  void didUpdateWidget(ChatMessageList old) {
    super.didUpdateWidget(old);
    final count = widget.messages.length;
    if (count <= _shown || count < old.messages.length) {
      _shown = count; // reloaded or nothing new
      return;
    }
    if (_atBottom || widget.messages.last.isMine) {
      _showAll();
      _toBottomAfterLayout();
    }
  }

  void _showAll() => _shown = widget.messages.length;

  void _toBottomAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        0,
        duration: context.motion(const Duration(milliseconds: 250)),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final messages = widget.messages;
    return Stack(
      children: [
        ListView.builder(
          controller: _scroll,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: _shown,
          itemBuilder: (context, i) =>
              ChatBubble(message: messages[_shown - 1 - i]),
        ),
        if (_pending > 0)
          PositionedDirectional(
            bottom: 12,
            start: 0,
            end: 0,
            child: Center(
              child: ActionChip(
                avatar: Icon(
                  Icons.arrow_downward_rounded,
                  size: 18,
                  color: m.onAccentFill,
                ),
                label: Text('new_messages'.tr()),
                labelStyle: TextStyle(color: m.onAccentFill),
                backgroundColor: m.accentFill,
                side: BorderSide.none,
                onPressed: () {
                  setState(_showAll);
                  _toBottomAfterLayout();
                },
              ),
            ),
          ),
      ],
    );
  }
}
