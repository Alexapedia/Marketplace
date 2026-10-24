import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../../../../core/utils/functions/open_product.dart';
import '../../controller/cart_cubit.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final name = item.displayName.isNotEmpty ? item.displayName : 'item'.tr();
    final details = [
      if (item.variant != null && item.variant!.isNotEmpty) item.variant!,
      if (item.size != null && item.size!.isNotEmpty) item.size!,
    ].join(' · ');
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () => openProductDetails(context, item.productId),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
            child: ColoredBox(
              color: m.surface2,
              child: ImageItem(
                item.cover,
                semanticLabel: name,
                width: 84,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: displayStyle(size: 16, color: m.ink, height: 1.2),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(color: m.inkMuted),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedNumber(
                        value: item.lineTotal,
                        format: (v) =>
                            '${v.toStringAsFixed(0)} ${AppString.currency}',
                        style: text.titleSmall?.copyWith(
                          color: m.accentInk,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _QtyPill(item: item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.item});
  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    void set(int q) {
      HapticFeedback.selectionClick();
      context.read<CartCubit>().updateQty(item.id, q);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: m.line),
        color: m.canvas,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'a11y_decrease_qty'.tr(),
            onPressed: () => set(item.quantity - 1),
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          AnimatedNumber(
            value: item.quantity.toDouble(),
            format: (v) => v.round().toString(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          IconButton(
            tooltip: 'a11y_increase_qty'.tr(),
            onPressed: () => set(item.quantity + 1),
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
