import 'package:flutter/material.dart';

import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/models/custom_order_models.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final mine = message.isMine;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 3),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mine
              ? gold.withValues(alpha: 0.18)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text.isNotEmpty) Text(message.text),
            ...message.images.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ImageItem(
                  e,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt!.toLocal().toString().substring(11, 16),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.48),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
