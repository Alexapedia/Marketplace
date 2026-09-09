import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/categories_cubit.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text('categories'.tr())),
        body: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state.status == RequestStatus.failed) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () => context.read<CategoriesCubit>().load(),
              );
            }
            final loading = state.status != RequestStatus.loaded;
            final items = loading
                ? List.generate(8, (_) => const CategoryModel(name: 'Category'))
                : state.items;
            if (!loading && items.isEmpty) {
              return EmptyState(
                title: 'empty_categories'.tr(),
                icon: Icons.category_outlined,
              );
            }
            return Skeletonizer(
              enabled: loading,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.92,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final c = items[i];
                  return GestureDetector(
                    onTap: () => context.pushNamed(
                      AppRouterKeys.products,
                      extra: {'categoryId': c.id, 'title': c.name},
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context)
                              .extension<AppColors>()!
                              .gold
                              .withValues(alpha: 0.18),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(
                            child: ImageItem(c.image, fit: BoxFit.cover, width: double.infinity),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              c.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
