import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/open_product.dart';
import '../../controller/order_details_cubit.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        padding: const EdgeInsets.all(12),
        onTap: () => openProductDetails(context, item.productId),
        child: Row(
          children: [
            ImageItem(
              item.cover,
              width: 64,
              height: 72,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: displayStyle(size: 16, color: m.ink, height: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '×${item.quantity}',
              style: text.titleSmall
                  ?.copyWith(color: m.accentInk, fontWeight: FontWeight.w700)
                  .tabular,
            ),
            if (item.productId.isNotEmpty)
              IconButton(
                tooltip: 'rate_product'.tr(),
                onPressed: () => showRateSheet(
                  context: context,
                  title: 'rate_product'.tr(),
                  onSubmit: (rating, comment) => context
                      .read<OrderDetailsCubit>()
                      .rateProduct(item.productId, rating, comment),
                ),
                icon: Icon(Icons.star_outline_rounded, color: m.accentInk),
              ),
          ],
        ),
      ),
    );
  }
}
