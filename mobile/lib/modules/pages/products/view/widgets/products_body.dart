import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/products_cubit.dart';
import 'products_filter_sheet.dart';
import 'products_grid_with_ads.dart';

class ProductsBody extends StatelessWidget {
  const ProductsBody({super.key, this.autofocus = false});

  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cubit.searchController,
                  autofocus: autofocus,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'search_hint'.tr(),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: cubit.onSearchChanged,
                  onSubmitted: (v) => cubit.load(search: v),
                ),
              ),
              const SizedBox(width: 8),
              BlocBuilder<ProductsCubit, ProductsState>(
                buildWhen: (a, b) => a.hasFilters != b.hasFilters,
                builder: (context, state) => IconButton.filledTonal(
                  tooltip: 'filters'.tr(),
                  onPressed: () => showProductsFilterSheet(context, cubit),
                  icon: Badge(
                    isLabelVisible: state.hasFilters,
                    smallSize: 8,
                    child: const Icon(Icons.tune),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state.status == RequestStatus.failed) {
                return FailedShape(
                  msg: state.error,
                  onTapRefresh: cubit.load,
                );
              }
              final loading = state.status != RequestStatus.loaded;
              final items = loading
                  ? List.generate(
                      6,
                      (_) => const ProductModel(name: 'Loading product', price: 99),
                    )
                  : state.items;
              if (!loading && items.isEmpty) {
                return EmptyState(
                  title: 'empty_products'.tr(),
                  icon: Icons.inventory_2_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: () => cubit.load(),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 400) {
                      cubit.loadMore();
                    }
                    return false;
                  },
                  child: Skeletonizer(
                    enabled: loading,
                    child: ProductsGridWithAds(
                      products: items,
                      ads: loading ? const [] : state.ads,
                      loadingMore: state.loadingMore,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
