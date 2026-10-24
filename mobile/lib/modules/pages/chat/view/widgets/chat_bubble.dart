import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/custom_order_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final mine = message.isMine;
    final fg = mine ? m.onAccent : m.ink;
    final big = const Radius.circular(20);
    final small = const Radius.circular(6);
    // The tail sits on the sender's side of the reading direction.
    final radius = BorderRadiusDirectional.only(
      topStart: big,
      topEnd: big,
      bottomStart: mine ? big : small,
      bottomEnd: mine ? small : big,
    );
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: mine ? m.accent : m.surface,
          borderRadius: radius,
          border: mine ? null : Border.all(color: m.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.text.isNotEmpty)
              Text(
                message.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: fg),
              ),
            ...message.images.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ImageItem(
                  e,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                message.createdAt!.toLocal().toString().substring(11, 16),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: fg.withValues(alpha: 0.72))
                    .tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
