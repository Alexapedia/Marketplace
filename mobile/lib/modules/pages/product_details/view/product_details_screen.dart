import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/components/product_card.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/require_auth.dart';
import '../controller/product_details_cubit.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailsCubit()..load(productId),
      child: const _DetailsBody(),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody();

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        if (state.status == RequestStatus.loading ||
            state.status == RequestStatus.init) {
          return const Scaffold(body: LoadingItem());
        }
        if (state.status == RequestStatus.failed || state.product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: FailedShape(
              msg: state.error,
              onTapRefresh: () =>
                  context.read<ProductDetailsCubit>().load(productIdFrom(state)),
            ),
          );
        }
        final p = state.product!;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: () => requireAuth(
                      context,
                      () => context.read<ProductDetailsCubit>().toggleFav(),
                    ),
                    icon: Icon(
                      p.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: p.isFavorite ? Colors.redAccent : gold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: '${'share_product'.tr()} ${p.name}'),
                      );
                      AppToast('share');
                    },
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _Gallery(images: p.images.isEmpty ? [''] : p.images),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${p.displayPrice.toStringAsFixed(0)} ${'currency'.tr()}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: gold,
                            ),
                          ),
                          if (p.isOnSale) ...[
                            const SizedBox(width: 10),
                            Text(
                              p.price.toStringAsFixed(0),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            p.inStock
                                ? 'stock_count'.tr(namedArgs: {'count': '${p.stock}'})
                                : 'out_of_stock'.tr(),
                            style: TextStyle(
                              color: p.inStock
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      if (p.sizes.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Text('size'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: p.sizes
                              .map(
                                (s) => ChoiceChip(
                                  label: Text(s),
                                  selected: state.selectedSize == s,
                                  onSelected: (_) =>
                                      context.read<ProductDetailsCubit>().setSize(s),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text('quantity'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => context
                                .read<ProductDetailsCubit>()
                                .setQty(state.quantity - 1),
                            icon: const Icon(Icons.remove),
                          ),
                          Text('${state.quantity}', style: const TextStyle(fontSize: 18)),
                          IconButton.filledTonal(
                            onPressed: () => context
                                .read<ProductDetailsCubit>()
                                .setQty(state.quantity + 1),
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('description'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(p.description.isEmpty ? '—' : p.description),
                      if (p.related.isNotEmpty) ...[
                        SectionHeader(title: 'related'.tr()),
                        SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: p.related.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, i) => SizedBox(
                              width: 160,
                              child: ProductCard(product: p.related[i], index: i),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: AppButton(
                onTap: p.inStock
                    ? () => AppControllerCubit.get(context).addToCart(
                          context,
                          productId: p.id,
                          size: state.selectedSize,
                          quantity: state.quantity,
                        )
                    : null,
                title: p.inStock ? 'add_to_cart'.tr() : 'out_of_stock'.tr(),
              ),
            ),
          ),
        );
      },
    );
  }

  String productIdFrom(ProductDetailsState state) => state.product?.id ?? '';
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.images});
  final List<String> images;
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final controller = PageController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(backgroundColor: Colors.black),
              body: PhotoViewGallery.builder(
                itemCount: widget.images.length,
                builder: (context, i) => PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.images[i]),
                  minScale: PhotoViewComputedScale.contained,
                ),
              ),
            ),
          ),
        );
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: widget.images.length,
            itemBuilder: (context, i) => ImageItem(widget.images[i], fit: BoxFit.cover),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: controller,
                  count: widget.images.length,
                  effect: WormEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    activeDotColor: Theme.of(context).extension<AppColors>()!.gold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
