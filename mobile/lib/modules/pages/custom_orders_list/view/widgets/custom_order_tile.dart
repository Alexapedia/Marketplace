import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/models/custom_order_models.dart';
import '../../../../../core/utils/functions/status_label.dart';

class CustomOrderTile extends StatelessWidget {
  const CustomOrderTile({super.key, required this.order});

  final CustomOrderModel order;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final short = order.id.length > 8
        ? order.id.substring(order.id.length - 8)
        : order.id;
    return ListTile(
      onTap: () => context.pushNamed(
        AppRouterKeys.customOrderDetails,
        extra: order.id,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(
        backgroundColor: gold.withValues(alpha: 0.15),
        child: Icon(Icons.auto_awesome, color: gold),
      ),
      title: Text(
        order.categoryName.isNotEmpty ? order.categoryName : '#$short',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        order.description.isNotEmpty
            ? order.description
            : statusLabel(order.status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        statusLabel(order.status),
        style: TextStyle(color: gold, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
