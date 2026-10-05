import 'package:flutter/material.dart';

import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../controller/product_details_cubit.dart';
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
  });

  final ProductModel product;
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: CircleBackButton(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ProductShareButton(product: product),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                child: ProductFavoriteButton(product: product),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProductGallery(
                images: product.images.isEmpty ? [''] : product.images,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ProductInfo(
                product: product,
                state: state,
                compact: false,
                showRelated: true,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: ProductQtyAddBar(product: product, state: state),
    );
  }
}
