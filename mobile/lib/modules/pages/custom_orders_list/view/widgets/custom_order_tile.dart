import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/custom_order_models.dart';
import '../../../../../core/utils/functions/status_label.dart';

class CustomOrderTile extends StatelessWidget {
  const CustomOrderTile({super.key, required this.order});

  final CustomOrderModel order;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final short = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;
    return SurfaceCard(
      onTap: () =>
          context.pushNamed(AppRouterKeys.customOrderDetails, extra: order.id),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: m.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_outlined, color: m.accentInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.categoryName.isNotEmpty
                      ? order.categoryName
                      : '#$short',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: displayStyle(size: 17, color: m.ink),
                ),
                if (order.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(color: m.inkMuted),
                  ),
                ],
                const SizedBox(height: 8),
                StatusPill(
                  status: order.status,
                  label: statusLabel(order.status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
