import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../../../../core/utils/functions/open_product.dart';
import '../../controller/cart_cubit.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final name = item.product?.name ?? 'item'.tr();
    return InkWell(
      onTap: () => openProductDetails(context, item.productId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageItem(
                item.product?.cover ?? '',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (item.size != null)
                    Text(
                      item.size!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  Text(
                    '${item.lineTotal.toStringAsFixed(0)} ${AppString.currency}',
                    style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context
                        .read<CartCubit>()
                        .updateQty(item.id, item.quantity - 1),
                    icon: const Icon(Icons.remove, size: 18),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context
                        .read<CartCubit>()
                        .updateQty(item.id, item.quantity + 1),
                    icon: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
