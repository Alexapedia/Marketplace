import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/responsive.dart';

class ProductRelatedGrid extends StatelessWidget {
  const ProductRelatedGrid({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'related'.tr()),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: context.catalogColumns.clamp(2, 4),
            childAspectRatio: 0.62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, i) => ProductCard(
            product: products[i],
            index: i,
            heroScope: 'related-$i',
          ),
        ),
      ],
    );
  }
}
