import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/product_card.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/favorites_cubit.dart';

class FavoritesBody extends StatelessWidget {
  const FavoritesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    if (isGuest) {
      return EmptyState(
        title: 'login_required'.tr(),
        subtitle: 'login_required_desc'.tr(),
        icon: Icons.favorite_border,
        action: AppButton(
          onTap: () => requireAuth(context, () {}),
          title: 'login'.tr(),
          size: const Size(220, 48),
        ),
      );
    }
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(
            msg: state.error,
            onTapRefresh: () => context.read<FavoritesCubit>().load(),
          );
        }
        final loading = state.status != RequestStatus.loaded;
        final items = loading
            ? List.generate(
                4,
                (_) => const ProductModel(name: 'Item', price: 10),
              )
            : state.items;
        if (!loading && items.isEmpty) {
          return EmptyState(
            title: 'empty_favorites'.tr(),
            subtitle: 'empty_favorites_hint'.tr(),
            icon: Icons.favorite_border,
          );
        }
        return Skeletonizer(
          enabled: loading,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.catalogColumns,
              mainAxisExtent: context.byDevice(
                mobile: 240,
                mobileLandscape: 220,
                tablet: 250,
                desktop: 260,
              ),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => ProductCard(
              product: items[i],
              index: i,
              heroScope: 'fav-$i',
            ),
          ),
        );
      },
    );
  }
}
