import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/skeleton_placeholders.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/product_details_cubit.dart';
import 'product_portrait_view.dart';
import 'product_split_view.dart';

class ProductDetailsBody extends StatelessWidget {
  const ProductDetailsBody({super.key, this.heroTag = '', this.heroImage = ''});

  /// Shared-element tag and image from the card that opened this screen.
  final String heroTag;
  final String heroImage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        if (state.status == RequestStatus.loading ||
            state.status == RequestStatus.init) {
          return _Loading(heroTag: heroTag, heroImage: heroImage);
        }
        if (state.status == RequestStatus.failed || state.product == null) {
          return Scaffold(
            appBar: AppBar(leading: const CircleBackButton()),
            body: FailedShape(
              msg: state.error,
              onTapRefresh: () =>
                  context.read<ProductDetailsCubit>().load(state.productId),
            ),
          );
        }
        final product = state.product!;
        if (context.useNavRail) {
          return ProductSplitView(
            product: product,
            state: state,
            heroTag: heroTag,
          );
        }
        return ProductPortraitView(
          product: product,
          state: state,
          heroTag: heroTag,
        );
      },
    );
  }
}

/// Loading state: the flying image lands in place while the rest shimmers.
class _Loading extends StatelessWidget {
  const _Loading({required this.heroTag, required this.heroImage});
  final String heroTag;
  final String heroImage;

  @override
  Widget build(BuildContext context) {
    final split = context.useNavRail;
    final image = ImageItem(
      heroImage,
      fit: BoxFit.cover,
      heroTag: heroTag.isEmpty ? null : heroTag,
    );
    const back = PositionedDirectional(
      start: 12,
      top: 8,
      child: SafeArea(child: CircleBackButton()),
    );
    if (split) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 10,
              child: Stack(fit: StackFit.expand, children: [image, back]),
            ),
            const Expanded(flex: 11, child: SkeletonDetail(heroHeight: 0)),
          ],
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: _galleryHeight(context),
            width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [image, back]),
          ),
          const Expanded(child: SkeletonDetail(heroHeight: 0)),
        ],
      ),
    );
  }
}

double _galleryHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.52).clamp(320.0, 520.0);

/// Height of the portrait gallery, shared with the loaded view so the hero
/// lands where the gallery will be.
double productGalleryHeight(BuildContext context) => _galleryHeight(context);
