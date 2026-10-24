import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../controller/product_details_cubit.dart';
import 'product_details_body.dart';
import 'product_favorite_button.dart';
import 'product_gallery.dart';
import 'product_info.dart';
import 'product_qty_add_bar.dart';
import 'product_share_button.dart';

class ProductPortraitView extends StatelessWidget {
  const ProductPortraitView({
    super.key,
    required this.product,
    required this.state,
    this.heroTag = '',
  });

  final ProductModel product;
  final ProductDetailsState state;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final galleryHeight = productGalleryHeight(context);
    return Scaffold(
      extendBody: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: galleryHeight,
            pinned: true,
            stretch: true,
            backgroundColor: m.canvas,
            leadingWidth: 64,
            leading: const Padding(
              padding: EdgeInsetsDirectional.only(start: 12),
              child: Center(child: CircleBackButton()),
            ),
            actions: [
              ProductShareButton(product: product),
              const SizedBox(width: 4),
              ProductFavoriteButton(product: product),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: ProductGallery(
                images: product.images.isEmpty ? [''] : product.images,
                heroTag: heroTag,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: ProductInfo(
                product: product,
                state: state,
                compact: false,
                showRelated: true,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: ProductQtyAddBar(product: product, state: state),
    );
  }
}
