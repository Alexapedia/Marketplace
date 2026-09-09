import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_controller/app_controller_cubit.dart';
import '../../config/routing/app_router_keys.dart';
import '../models/catalog_models.dart';
import '../models/color_model.dart';
import '../utils/functions/require_auth.dart';
import 'image_item.dart';
import 'text_with_hero.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, this.index = 0});

  final ProductModel product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.extension<AppColors>()!.gold;
    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRouterKeys.productDetails,
        extra: {'id': product.id, 'index': index},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageItem(product.cover, fit: BoxFit.cover, heroTag: 'p-${product.id}'),
                  if (product.isOnSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'sale'.tr(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                      ),
                      onPressed: () => requireAuth(
                        context,
                        () => AppControllerCubit.get(context).toggleFavorite(context, product.id),
                      ),
                      icon: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? Colors.redAccent : gold,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroText(
                    tag: 'name-${product.id}',
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.displayPrice.toStringAsFixed(0)} ${'currency'.tr()}',
                        style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                      ),
                      if (product.isOnSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          product.price.toStringAsFixed(0),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 8, 10),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const Spacer(),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text('see_all'.tr())),
        ],
      ),
    );
  }
}
