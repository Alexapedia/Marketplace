import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/app_button.dart';
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
    return SafeArea(
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
                onTap: product.inStock
                    ? () => AppControllerCubit.get(context).addToCart(
                          context,
                          productId: product.id,
                          size: state.selectedSize,
                          quantity: state.quantity,
                        )
                    : null,
                title: product.inStock
                    ? 'add_to_cart'.tr()
                    : 'out_of_stock'.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
