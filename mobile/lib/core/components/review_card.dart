import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../models/color_model.dart';
import '../models/review_models.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.compact = false});

  final ReviewModel review;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final theme = Theme.of(context);
    return Container(
      width: compact ? 260 : double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'Z',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.userName.isEmpty ? 'customer'.tr() : review.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              StarRating(value: review.rating, size: 14),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                review.comment,
                maxLines: compact ? 4 : 8,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1.45,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showRateSheet({
  required BuildContext context,
  required String title,
  required Future<void> Function(double rating, String comment) onSubmit,
  double initial = 5,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) =>
        _RateSheet(title: title, initial: initial, onSubmit: onSubmit),
  );
}

class _RateSheet extends StatefulWidget {
  const _RateSheet({
    required this.title,
    required this.onSubmit,
    required this.initial,
  });
  final String title;
  final double initial;
  final Future<void> Function(double rating, String comment) onSubmit;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  late double _rating;
  final _comment = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initial;
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 12),
          StarRating(
            value: _rating,
            size: 36,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'rating_comment_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: const Color(0xFF12141C),
              ),
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        await widget.onSubmit(_rating, _comment.text.trim());
                        if (context.mounted) Navigator.pop(context);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(_busy ? 'loading'.tr() : 'submit_rating'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}
