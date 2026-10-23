import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import 'product_circle_action.dart';

class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    super.key,
    required this.product,
    this.filled = false,
  });

  final ProductModel product;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return BlocSelector<AppControllerCubit, AppControllerState, bool>(
      selector: (s) =>
          s.favoritesReady ? s.isFavorite(product.id) : product.isFavorite,
      builder: (context, isFav) {
        final icon = Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: isFav ? Colors.redAccent : gold,
        );
        void onTap() {
          HapticFeedback.selectionClick();
          AppControllerCubit.get(context).toggleFavorite(context, product.id);
        }

        final label = isFav
            ? 'a11y_remove_favorite'.tr()
            : 'a11y_add_favorite'.tr();
        if (filled) {
          return Semantics(
            selected: isFav,
            child: ProductCircleAction(
              tooltip: label,
              icon: isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : gold,
              onTap: onTap,
            ),
          );
        }
        return Semantics(
          selected: isFav,
          child: IconButton.filledTonal(
            tooltip: label,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.92)
                  : Colors.black.withValues(alpha: 0.92),
            ),
            onPressed: onTap,
            icon: icon,
          ),
        );
      },
    );
  }
}
