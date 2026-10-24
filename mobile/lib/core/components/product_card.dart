import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_controller/app_controller_cubit.dart';
import '../../config/routing/app_router_keys.dart';
import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../../config/theme/typography.dart';
import '../models/catalog_models.dart';
import '../utils/constant/app_string.dart';
import '../utils/functions/product_hero.dart';
import 'image_item.dart';
import 'maison.dart';
import 'star_rating.dart';
import 'text_with_hero.dart';

/// Maison product card: a tall image well with the price and name set
/// beneath on the card surface, hairline border and shadow-1. The image is
/// the shared element that flies into the details screen.
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

  void _open(BuildContext context, String imageTag) {
    ProductHero.prime(product.id, imageTag, product.cover);
    context.pushNamed(
      AppRouterKeys.productDetails,
      extra: {'id': product.id, 'index': index},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = context.maison;
    final imageTag = '$heroScope-img-${product.id}';
    final nameTag = '$heroScope-name-${product.id}';
    final bigText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return RepaintBoundary(
      child: Pressable(
        child: Container(
          decoration: BoxDecoration(
            color: m.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: m.line),
            boxShadow: AppShadows.one(m.brightness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _open(context, imageTag),
              borderRadius: AppRadius.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(color: m.surface2),
                        ImageItem(
                          product.cover,
                          fit: BoxFit.cover,
                          heroTag: imageTag,
                          semanticLabel: product.name,
                        ),
                        if (product.isOnSale)
                          PositionedDirectional(
                            top: 10,
                            start: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: m.accentInk,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                'sale'.tr(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Maison.onColor(m.accentInk),
                                ),
                              ),
                            ),
                          ),
                        PositionedDirectional(
                          top: 0,
                          end: 0,
                          child: _FavoriteToggle(product: product),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            AppSpacing.sm,
                            10,
                            AppSpacing.sm,
                            10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeroText(
                                tag: nameTag,
                                child: Text(
                                  product.name.isEmpty ? ' ' : product.name,
                                  // Large text scales: one line so the
                                  // price row still fits.
                                  maxLines: bigText ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: displayStyle(
                                    size: 15,
                                    weight: FontWeight.w600,
                                    height: 1.2,
                                    color: m.ink,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              if (product.ratingCount > 0 || !bigText)
                                StarRating(
                                  value: product.ratingAvg,
                                  size: 12,
                                  showValue: product.ratingCount > 0,
                                ),
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Dropped at large text scales;
                                        // the sale price remains.
                                        if (product.isOnSale && !bigText)
                                          Text(
                                            product.price.toStringAsFixed(0),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: m.inkMuted,
                                                )
                                                .tabular,
                                          ),
                                        Text(
                                          '${product.displayPrice.toStringAsFixed(0)} ${AppString.currency}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                color: m.accentInk,
                                                fontWeight: FontWeight.w700,
                                              )
                                              .tabular,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: m.accentFill,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      size: 18,
                                      color: m.onAccentFill,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Transparent 48x48 hit box centred over the visual.
                        PositionedDirectional(
                          end: 4,
                          bottom: 2,
                          width: 48,
                          height: 48,
                          child: Semantics(
                            button: true,
                            label: 'a11y_add_to_cart'.tr(args: [product.name]),
                            child: InkWell(
                              key: const ValueKey('add-to-cart-hit'),
                              customBorder: const CircleBorder(),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                AppControllerCubit.get(
                                  context,
                                ).addToCart(context, productId: product.id);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteToggle extends StatelessWidget {
  const _FavoriteToggle({required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return BlocSelector<AppControllerCubit, AppControllerState, bool>(
      selector: (s) =>
          s.favoritesReady ? s.isFavorite(product.id) : product.isFavorite,
      builder: (context, isFav) {
        void toggle() {
          HapticFeedback.selectionClick();
          AppControllerCubit.get(context).toggleFavorite(context, product.id);
        }

        return Semantics(
          button: true,
          selected: isFav,
          label: isFav ? 'a11y_remove_favorite'.tr() : 'a11y_add_favorite'.tr(),
          excludeSemantics: true,
          onTap: toggle,
          child: IconButton(
            onPressed: toggle,
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
            ),
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: m.surface.withValues(alpha: 0.88),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : AppDurations.fast,
                transitionBuilder: (c, a) => ScaleTransition(
                  scale: CurvedAnimation(parent: a, curve: AppCurves.spring),
                  child: c,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFav),
                  color: isFav ? m.danger : m.ink,
                  size: 17,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Legacy section header; now the Maison header (display title + gold rule).
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.eyebrow,
  });
  final String title;
  final VoidCallback? onSeeAll;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) =>
      MaisonSectionHeader(title: title, eyebrow: eyebrow, onSeeAll: onSeeAll);
}
