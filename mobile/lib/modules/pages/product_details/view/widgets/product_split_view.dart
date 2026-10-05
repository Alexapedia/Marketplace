import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/product_details_cubit.dart';
import 'product_favorite_button.dart';
import 'product_gallery.dart';
import 'product_info.dart';
import 'product_qty_add_bar.dart';
import 'product_share_button.dart';

class ProductSplitView extends StatelessWidget {
  const ProductSplitView({
    super.key,
    required this.product,
    required this.state,
  });

  final ProductModel product;
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: context.locale.languageCode == 'ar',
        right: context.locale.languageCode == 'en',
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Stack(
                  children: [
                    ProductGallery(
                      images: product.images.isEmpty ? [''] : product.images,
                      showThumbs: !context.isCompactHeight,
                    ),
                    const PositionedDirectional(
                      start: 12,
                      top: 12,
                      child: CircleBackButton(),
                    ),
                    if (!context.isCompactHeight) ...[
                      PositionedDirectional(
                        end: 52,
                        top: 12,
                        child: ProductShareButton(
                          product: product,
                          filled: true,
                        ),
                      ),
                      PositionedDirectional(
                        end: 12,
                        top: 12,
                        child: ProductFavoriteButton(
                          product: product,
                          filled: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 11,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: ProductInfo(
                        product: product,
                        state: state,
                        compact: context.isCompactHeight,
                      ),
                    ),
                  ),
                  ProductQtyAddBar(product: product, state: state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
