import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/categories_cubit.dart';
import 'category_tile.dart';

class CategoriesBody extends StatelessWidget {
  const CategoriesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.catalogColumns.clamp(2, 4),
              mainAxisExtent: ResponsiveUtils.byDevice(
                context: context,
                mobileLandscape: 160,
                mobile: 180,
                tablet: 180,
                desktop: 180,
              ),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => CategoryTile(category: items[i]),
          ),
        );
      },
    );
  }
}
