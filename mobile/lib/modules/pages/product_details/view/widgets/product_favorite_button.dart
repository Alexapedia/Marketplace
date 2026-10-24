import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import 'product_circle_action.dart';

class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    super.key,
    required this.product,
    this.filled = false,
  });

  final ProductModel product;

  /// Kept for API compatibility; both variants are the glass circle.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return BlocSelector<AppControllerCubit, AppControllerState, bool>(
      selector: (s) =>
          s.favoritesReady ? s.isFavorite(product.id) : product.isFavorite,
      builder: (context, isFav) {
        return Semantics(
          selected: isFav,
          child: ProductCircleAction(
            tooltip: isFav
                ? 'a11y_remove_favorite'.tr()
                : 'a11y_add_favorite'.tr(),
            icon: isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? m.danger : m.ink,
            onTap: () => AppControllerCubit.get(
              context,
            ).toggleFavorite(context, product.id),
          ),
        );
      },
    );
  }
}
