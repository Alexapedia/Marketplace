import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/star_rating.dart';
import '../../../../../core/models/catalog_models.dart';
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
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final variant = product.variantFor(state.selectedVariant);
    final unitPrice = product.priceFor(state.selectedVariant);
    final stock = product.stockFor(state.selectedVariant);
    final showSale = variant?.price == null && product.isOnSale;
    var i = 0;
    Widget r(Widget w) => Reveal(index: i++, child: w);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.categoryName.isNotEmpty) ...[
          r(Eyebrow(product.categoryName)),
          const SizedBox(height: 8),
        ],
        r(
          Text(
            product.name.isEmpty ? '—' : product.name,
            style: displayStyle(size: compact ? 24 : 30, color: m.ink),
          ),
        ),
        const SizedBox(height: 10),
        r(
          StarRating(
            value: product.ratingAvg,
            size: 16,
            showValue: true,
            count: product.ratingCount,
          ),
        ),
        const SizedBox(height: 16),
        r(
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedNumber(
                value: unitPrice,
                format: (v) => '${v.toStringAsFixed(0)} ${AppString.currency}',
                style: text.headlineMedium!.copyWith(
                  fontFamily: kFontFamily,
                  fontFamilyFallback: const [],
                  fontVariations: const [],
                  fontWeight: FontWeight.w600,
                  color: m.accentInk,
                ),
              ),
              if (showSale) ...[
                const SizedBox(width: 10),
                Text(
                  product.price.toStringAsFixed(0),
                  style: text.bodyMedium!
                      .copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: m.inkMuted,
                      )
                      .tabular,
                ),
              ],
              const Spacer(),
              _StockPill(stock: stock),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const GoldRule(width: 64, draw: true),
        if (product.variants.isNotEmpty) ...[
          const SizedBox(height: 20),
          r(Eyebrow('options'.tr(), color: m.inkMuted)),
          const SizedBox(height: 10),
          r(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.variants
                  .map(
                    (v) => ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        v.price == null
                            ? v.key
                            : '${v.key} · ${v.price!.toStringAsFixed(0)} ${AppString.currency}',
                      ),
                      selected: state.selectedVariant == v.key,
                      onSelected: v.inStock
                          ? (_) => context
                                .read<ProductDetailsCubit>()
                                .setVariant(v.key)
                          : null,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (product.sizes.isNotEmpty) ...[
          const SizedBox(height: 20),
          r(Eyebrow('size'.tr(), color: m.inkMuted)),
          const SizedBox(height: 10),
          r(
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.sizes
                  .map(
                    (s) => ChoiceChip(
                      showCheckmark: false,
                      label: Text(s),
                      selected: state.selectedSize == s,
                      onSelected: (_) =>
                          context.read<ProductDetailsCubit>().setSize(s),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        if (!compact) ...[
          const SizedBox(height: 20),
          r(
            Text(
              product.description.isEmpty ? '—' : product.description,
              style: text.bodyLarge!.copyWith(height: 1.7, color: m.inkMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          r(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductInfoTile(
                  icon: Icons.local_shipping_outlined,
                  label: 'delivery_eta'.tr(),
                ),
                const SizedBox(width: 8),
                ProductInfoTile(
                  icon: Icons.payments_outlined,
                  label: 'cod'.tr(),
                ),
                const SizedBox(width: 8),
                ProductInfoTile(
                  icon: Icons.replay_outlined,
                  label: 'returns_14'.tr(),
                ),
              ],
            ),
          ),
        ],
        if (showRelated) ProductRelatedGrid(products: product.related),
        ProductReviews(product: product, state: state),
      ],
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final ok = stock > 0;
    final color = ok ? m.success : m.danger;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          ok
              ? 'stock_count'.tr(namedArgs: {'count': '$stock'})
              : 'out_of_stock'.tr(),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
