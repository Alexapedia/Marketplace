import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../../../../core/utils/functions/status_label.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final short = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;
    final covers = order.items.take(1).toList();
    final date = order.createdAt == null
        ? ''
        : DateFormat.yMMMd(context.locale.toString()).format(order.createdAt!);
    return SurfaceCard(
      onTap: () =>
          context.pushNamed(AppRouterKeys.orderDetails, extra: order.id),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (covers.isEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: m.accentSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.local_mall_outlined, color: m.accentInk),
                  )
                else
                  ImageItem(
                    covers.first.cover,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(14),
                  ),
                if (order.items.length > 1)
                  PositionedDirectional(
                    end: -6,
                    bottom: -6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: m.accent,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: m.surface, width: 2),
                      ),
                      child: Text(
                        '+${order.items.length - 1}',
                        style: text.labelSmall?.copyWith(
                          color: m.onAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'order_number'.tr(args: ['#$short']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: displayStyle(size: 16, color: m.ink),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: text.labelMedium?.copyWith(color: m.inkMuted),
                  ),
                ],
                const SizedBox(height: 8),
                _StatusPill(status: order.status),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${order.total.toStringAsFixed(0)} ${AppString.currency}',
            style: text.titleSmall
                ?.copyWith(color: m.accentInk, fontWeight: FontWeight.w700)
                .tabular,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final bad = status == 'rejected' || status == 'cancelled';
    final good = status == 'delivered' || status == 'completed';
    final color = bad ? m.danger : (good ? m.success : m.accentInk);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              statusLabel(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
