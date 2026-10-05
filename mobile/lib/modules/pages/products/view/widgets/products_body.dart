import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/products_cubit.dart';
import 'products_grid_with_ads.dart';

class ProductsBody extends StatelessWidget {
  const ProductsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductsCubit>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: cubit.searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'search_hint'.tr(),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: cubit.onSearchChanged,
            onSubmitted: (v) => cubit.load(search: v),
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
                      (_) => const ProductModel(name: 'Product', price: 99),
                    )
                  : state.items;
              if (!loading && items.isEmpty) {
                return EmptyState(
                  title: 'empty_products'.tr(),
                  icon: Icons.inventory_2_outlined,
                );
              }
              return Skeletonizer(
                enabled: loading,
                child: ProductsGridWithAds(
                  products: items,
                  ads: loading ? const [] : state.ads,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
