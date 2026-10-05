import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/components/product_card.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/models/review_models.dart';

class ReviewsStrip extends StatelessWidget {
  const ReviewsStrip({super.key, required this.reviews, this.stacked = false});

  final List<ReviewModel> reviews;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'customer_reviews'.tr()),
        if (stacked)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (final r in reviews.take(4)) ...[
                  ReviewCard(review: r),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) =>
                  ReviewCard(review: reviews[i], compact: true),
            ),
          ),
      ],
    );
  }
}
