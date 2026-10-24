import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/components/maison.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/models/review_models.dart';

class ReviewsStrip extends StatelessWidget {
  const ReviewsStrip({super.key, required this.reviews, this.stacked = false});

  final List<ReviewModel> reviews;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaisonSectionHeader(
          title: 'customer_reviews'.tr(),
          eyebrow: 'eyebrow_voices'.tr(),
        ),
        if (stacked)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final r in reviews.take(4)) ...[
                  ReviewCard(review: r),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          )
        else
          SizedBox(
            // Grows with the text scale so the card never clips.
            height: 190 * scale.clamp(1.0, 1.6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => Reveal(
                index: i,
                child: ReviewCard(review: reviews[i], compact: true),
              ),
            ),
          ),
      ],
    );
  }
}
