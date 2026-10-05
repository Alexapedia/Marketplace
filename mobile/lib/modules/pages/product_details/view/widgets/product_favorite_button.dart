import 'package:flutter/material.dart';
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
      selector: (s) => s.favoritesReady ? s.isFavorite(product.id) : product.isFavorite,
      builder: (context, isFav) {
        final icon = Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 18,
          color: isFav ? Colors.redAccent : gold,
        );
        void onTap() =>
            AppControllerCubit.get(context).toggleFavorite(context, product.id);
        if (filled) {
          return ProductCircleAction(
            icon: isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.redAccent : gold,
            onTap: onTap,
          );
        }
        return IconButton.filledTonal(
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withValues(alpha: 0.92)
                : Colors.black.withValues(alpha: 0.92),
          ),
          onPressed: onTap,
          icon: icon,
        );
      },
    );
  }
}
