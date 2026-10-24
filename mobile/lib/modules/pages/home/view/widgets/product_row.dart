import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../../../../core/utils/functions/responsive.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.title,
    required this.products,
    required this.loading,
    required this.query,
    required this.heroScope,
    this.columns,
    this.eyebrow,
  });

  final String title;
  final List<ProductModel> products;
  final bool loading;
  final Map<String, dynamic> query;
  final String heroScope;
  final int? columns;
  final String? eyebrow;

  /// Staggered Maison entrance for the first cards (60ms, max 8). Keyed so
  /// a rebuild of the same item does not replay; skipped under reduced
  /// motion and while skeletons are showing.
  Widget _entrance(BuildContext context, int i, Widget child) {
    if (context.reduceMotion || loading) return child;
    return KeyedSubtree(
      key: ValueKey('$heroScope-$i-${products[i].id}'),
      child: Reveal(index: i, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = loading
        ? List.generate(
            4,
            (_) => const ProductModel(name: 'Product', price: 100),
          )
        : products;
    if (!loading && items.isEmpty) return const SizedBox.shrink();
    final cols = (columns ?? context.catalogColumns).clamp(2, 4);
    final shown = items.take(cols * 2).toList();
    final cardHeight = context.byDevice(
      mobile: 292,
      mobileLandscape: 260,
      tablet: 320,
      desktop: 340,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: title,
          eyebrow: eyebrow,
          onSeeAll: () => context.pushNamed(
            AppRouterKeys.products,
            extra: {'query': query, 'title': title},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < shown.length; i++)
                    SizedBox(
                      width: itemWidth,
                      // Wide cells: keep the card proportional so the
                      // text area does not open up.
                      height: context.isMobile
                          ? cardHeight * 1.0
                          : (itemWidth * 1.55).clamp(260.0, cardHeight * 1.0),
                      child: _entrance(
                        context,
                        i,
                        ProductCard(
                          product: shown[i],
                          index: i,
                          heroScope: '$heroScope-$i',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
