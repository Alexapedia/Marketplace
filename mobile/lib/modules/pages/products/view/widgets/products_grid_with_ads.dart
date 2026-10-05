import 'package:flutter/material.dart';

import '../../../../../core/components/ad_banner_tile.dart';
import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/responsive.dart';

class ProductsGridWithAds extends StatelessWidget {
  const ProductsGridWithAds({
    super.key,
    required this.products,
    required this.ads,
  });

  final List<ProductModel> products;
  final List<BannerModel> ads;

  @override
  Widget build(BuildContext context) {
    final columns = context.catalogColumns;
    final rowsPerAd = 2;
    final chunkSize = columns * rowsPerAd;
    final slivers = <Widget>[];
    var adIndex = 0;

    for (var i = 0; i < products.length; i += chunkSize) {
      final chunk = products.sublist(
        i,
        i + chunkSize > products.length ? products.length : i + chunkSize,
      );
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: context.byDevice(
                mobile: 240,
                mobileLandscape: 220,
                tablet: 250,

                desktop: 260,
              ),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = chunk[index];
              return ProductCard(
                product: product,
                index: i + index,
                heroScope: 'grid-${i + index}',
              );
            }, childCount: chunk.length),
          ),
        ),
      );
      if (adIndex < ads.length && i + chunkSize < products.length) {
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(child: AdBannerTile(ad: ads[adIndex++])),
          ),
        );
      }
    }

    if (adIndex < ads.length) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverToBoxAdapter(child: AdBannerTile(ad: ads[adIndex])),
        ),
      );
    }

    return CustomScrollView(slivers: slivers);
  }
}
