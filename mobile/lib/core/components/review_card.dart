import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/typography.dart';
import '../models/review_models.dart';
import 'app_button.dart';
import 'star_rating.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.compact = false});

  final ReviewModel review;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final theme = Theme.of(context);
    final name = review.userName.isEmpty ? 'customer'.tr() : review.userName;
    return Container(
      width: compact ? 280 : double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: m.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: m.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              StarRating(value: review.rating, size: 14),
              const Spacer(),
              ExcludeSemantics(
                child: Text(
                  '“',
                  style: displayStyle(size: 36, color: m.accent, height: 0.6),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              maxLines: compact ? 4 : 8,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: m.ink,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: m.accentSoft,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: m.accentInk,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: m.inkMuted,
                  ),
                ),
              ),
            ],
          ),
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
    final m = context.maison;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: displayStyle(size: 22, color: m.ink)),
          const SizedBox(height: 16),
          StarRating(
            value: _rating,
            size: 36,
            onChanged: (v) => setState(() => _rating = v),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: InputDecoration(hintText: 'rating_comment_hint'.tr()),
          ),
          const SizedBox(height: 18),
          AppButton(
            isLoading: _busy,
            title: 'submit_rating'.tr(),
            onTap: () async {
              setState(() => _busy = true);
              try {
                await widget.onSubmit(_rating, _comment.text.trim());
                if (context.mounted) Navigator.pop(context);
              } finally {
                if (mounted) setState(() => _busy = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
