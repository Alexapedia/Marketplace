import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/open_product.dart';
import '../../controller/order_details_cubit.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return InkWell(
      onTap: () => openProductDetails(context, item.productId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gold.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageItem(
                item.cover,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'x${item.quantity}',
              style: TextStyle(fontWeight: FontWeight.w800, color: gold),
            ),
            if (item.productId.isNotEmpty) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'rate_product'.tr(),
                onPressed: () => showRateSheet(
                  context: context,
                  title: 'rate_product'.tr(),
                  onSubmit: (rating, comment) => context
                      .read<OrderDetailsCubit>()
                      .rateProduct(item.productId, rating, comment),
                ),
                icon: Icon(Icons.star_rate_rounded, color: gold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
