import 'package:flutter/material.dart';

import '../../../../../core/components/ad_banner_tile.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/responsive.dart';

class ProductsGridWithAds extends StatelessWidget {
  const ProductsGridWithAds({
    super.key,
    required this.products,
    required this.ads,
    this.loadingMore = false,
  });

  final List<ProductModel> products;
  final List<BannerModel> ads;
  final bool loadingMore;

  @override
  Widget build(BuildContext context) {
    final columns = context.catalogColumns;
    final rowsPerAd = 2;
    final chunkSize = columns * rowsPerAd;
    final slivers = <Widget>[];
    // Proportional cards: tall image well + text, never stretched.
    final width = MediaQuery.sizeOf(
      context,
    ).width.clamp(0.0, context.contentMaxWidth);
    final cell = (width - 32 - 12 * (columns - 1)) / columns;
    final extent = context.isMobile && context.isPortrait
        ? 292.0
        : (cell * 1.55).clamp(260.0, 340.0);
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
              mainAxisExtent: extent,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = chunk[index];
              final card = ProductCard(
                product: product,
                index: i + index,
                heroScope: 'grid-${i + index}',
              );
              // First screenful staggers in; later pages arrive quietly.
              return i + index < 8
                  ? Reveal(index: i + index, child: card)
                  : card;
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

    if (loadingMore) {
      slivers.add(
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 24),
          sliver: SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }
}
