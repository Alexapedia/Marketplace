import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/star_rating.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../controller/product_details_cubit.dart';
import 'product_info_tile.dart';
import 'product_related_grid.dart';
import 'product_reviews.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({
    super.key,
    required this.product,
    required this.state,
    required this.compact,
    this.showRelated = false,
  });

  final ProductModel product;
  final ProductDetailsState state;
  final bool compact;
  final bool showRelated;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.isEmpty ? '—' : product.name,
          style: TextStyle(
            fontSize: compact ? 18 : 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        StarRating(
          value: product.ratingAvg,
          size: compact ? 16 : 18,
          showValue: true,
          count: product.ratingCount,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${product.displayPrice.toStringAsFixed(0)} ${AppString.currency}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: gold,
              ),
            ),
            if (product.isOnSale) ...[
              const SizedBox(width: 8),
              Text(
                product.price.toStringAsFixed(0),
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          product.inStock
              ? 'stock_count'.tr(namedArgs: {'count': '${product.stock}'})
              : 'out_of_stock'.tr(),
          style: TextStyle(
            color: product.inStock
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
        if (product.sizes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: product.sizes
                .map(
                  (s) => ChoiceChip(
                    label: Text(s),
                    selected: state.selectedSize == s,
                    onSelected: (_) =>
                        context.read<ProductDetailsCubit>().setSize(s),
                  ),
                )
                .toList(),
          ),
        ],
        if (!compact) ...[
          const SizedBox(height: 10),
          Text(
            product.description.isEmpty ? '—' : product.description,
            style: TextStyle(
              height: 1.7,
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ProductInfoTile(
                icon: Icons.local_shipping_outlined,
                label: 'delivery_eta'.tr(),
              ),
              const SizedBox(width: 6),
              ProductInfoTile(icon: Icons.payments_outlined, label: 'cod'.tr()),
              const SizedBox(width: 6),
              ProductInfoTile(
                icon: Icons.replay_outlined,
                label: 'returns_14'.tr(),
              ),
            ],
          ),
        ],
        if (showRelated) ProductRelatedGrid(products: product.related),
        ProductReviews(product: product, state: state),
      ],
    );
  }
}
