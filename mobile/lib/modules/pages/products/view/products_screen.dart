import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/product_card.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../categories/controller/categories_cubit.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({
    super.key,
    this.title,
    this.categoryId,
    this.search,
    this.query = const {},
  });

  final String? title;
  final String? categoryId;
  final String? search;
  final Map<String, dynamic> query;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductsCubit cubit;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = ProductsCubit();
    searchController.text = widget.search ?? '';
    cubit.load(
      categoryId: widget.categoryId,
      search: widget.search,
      featured: widget.query['featured'] == true,
      newArrival: widget.query['newArrival'] == true,
      bestSeller: widget.query['bestSeller'] == true,
    );
  }

  @override
  void dispose() {
    cubit.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'search_products'.tr())),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'search_hint'.tr(),
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (v) => cubit.load(
                  categoryId: widget.categoryId,
                  search: v,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductsCubit, ProductsState>(
                builder: (context, state) {
                  if (state.status == RequestStatus.failed) {
                    return FailedShape(
                      msg: state.error,
                      onTapRefresh: () => cubit.load(categoryId: widget.categoryId),
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, i) =>
                          ProductCard(product: items[i], index: i),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
