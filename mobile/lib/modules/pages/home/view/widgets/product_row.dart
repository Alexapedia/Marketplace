import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/catalog_models.dart';
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
  });

  final String title;
  final List<ProductModel> products;
  final bool loading;
  final Map<String, dynamic> query;
  final String heroScope;
  final int? columns;

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
      mobile: 240,
      mobileLandscape: 220,
      tablet: 250,
      desktop: 260,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () => context.pushNamed(
            AppRouterKeys.products,
            extra: {'query': query, 'title': title},
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < shown.length; i++)
                    SizedBox(
                      width: itemWidth,
                      height: cardHeight*1.0,
                      child: ProductCard(
                        product: shown[i],
                        index: i,
                        heroScope: '$heroScope-$i',
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
