import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_controller/app_controller_cubit.dart';
import '../../config/routing/app_router_keys.dart';
import '../models/catalog_models.dart';
import '../models/color_model.dart';
import '../utils/functions/responsive.dart';
import 'image_item.dart';
import 'star_rating.dart';
import 'text_with_hero.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.index = 0,
    this.heroScope = 'p',
  });

  final ProductModel product;
  final int index;
  final String heroScope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.extension<AppColors>()!.gold;
    final imageTag = '$heroScope-img-${product.id}';
    final nameTag = '$heroScope-name-${product.id}';
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.pushNamed(
          AppRouterKeys.productDetails,
          extra: {'id': product.id, 'index': index},
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: gold.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageItem(
                      product.cover,
                      fit: BoxFit.cover,
                      heroTag: imageTag,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.28),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (product.isOnSale)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'sale'.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: BlocSelector<AppControllerCubit, AppControllerState, bool>(
                        selector: (s) =>
                            s.favoritesReady ? s.isFavorite(product.id) : product.isFavorite,
                        builder: (context, isFav) {
                          return IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.surface.withValues(
                                alpha: 0.92,
                              ),
                              minimumSize: const Size(34, 34),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => AppControllerCubit.get(
                              context,
                            ).toggleFavorite(context, product.id),
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : gold,
                              size: 18,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroText(
                        tag: nameTag,
                        child: Text(
                          product.name.isEmpty ? ' ' : product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            fontSize: context.font(13),
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      StarRating(
                        value: product.ratingAvg,
                        size: 12,
                        showValue: true,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.displayPrice.toStringAsFixed(0)} ${'currency'.tr()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                if (product.isOnSale)
                                  Text(
                                    product.price.toStringAsFixed(0),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: theme.colorScheme.onSurface.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => AppControllerCubit.get(context).addToCart(
                              context,
                              productId: product.id,
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? gold
                                    : AppColors.blackColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF12141C)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text('see_all'.tr())),
        ],
      ),
    );
  }
}
