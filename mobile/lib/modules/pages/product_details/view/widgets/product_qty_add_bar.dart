import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../controller/product_details_cubit.dart';

class ProductQtyAddBar extends StatelessWidget {
  const ProductQtyAddBar({
    super.key,
    required this.product,
    required this.state,
  });

  final ProductModel product;
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    final inStock = product.stockFor(state.selectedVariant) > 0;
    return GlassSurface(
      elevated: true,
      borderRadius: AppRadius.sheet,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'a11y_decrease_qty'.tr(),
                      onPressed: () => context
                          .read<ProductDetailsCubit>()
                          .setQty(state.quantity - 1),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${state.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      tooltip: 'a11y_increase_qty'.tr(),
                      onPressed: () => context
                          .read<ProductDetailsCubit>()
                          .setQty(state.quantity + 1),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onTap: inStock
                      ? () {
                          HapticFeedback.selectionClick();
                          AppControllerCubit.get(context).addToCart(
                            context,
                            productId: product.id,
                            variant: state.selectedVariant,
                            size: state.selectedSize,
                            quantity: state.quantity,
                          );
                        }
                      : null,
                  title: inStock ? 'add_to_cart'.tr() : 'out_of_stock'.tr(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
