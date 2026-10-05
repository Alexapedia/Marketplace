import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/review_card.dart';
import '../../../../../core/components/star_rating.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../controller/product_details_cubit.dart';

class ProductReviews extends StatelessWidget {
  const ProductReviews({
    super.key,
    required this.product,
    required this.state,
  });

  final ProductModel product;
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    final reviews = state.reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                'reviews'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            if (reviews.myReview == null)
              TextButton(
                onPressed: () => requireAuth(
                  context,
                  () => showRateSheet(
                    context: context,
                    title: 'rate_product'.tr(),
                    onSubmit: (rating, comment) => context
                        .read<ProductDetailsCubit>()
                        .submitReview(rating, comment),
                  ),
                ),
                child: Text('add_rating'.tr()),
              ),
          ],
        ),
        StarRating(
          value: product.ratingAvg,
          size: 18,
          showValue: true,
          count: product.ratingCount,
        ),
        const SizedBox(height: 10),
        if (reviews.items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('no_reviews_yet'.tr()),
          )
        else
          ...reviews.items.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ReviewCard(review: r),
            ),
          ),
      ],
    );
  }
}
