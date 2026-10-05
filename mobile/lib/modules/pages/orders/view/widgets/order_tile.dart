import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/status_label.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final short = order.id.length > 8 ? order.id.substring(0, 8) : order.id;
    return ListTile(
      onTap: () => context.pushNamed(
        AppRouterKeys.orderDetails,
        extra: order.id,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surface,
      leading: CircleAvatar(
        backgroundColor: gold.withValues(alpha: 0.15),
        child: Icon(Icons.local_mall_outlined, color: gold),
      ),
      title: Text('#$short'),
      subtitle: Text(statusLabel(order.status)),
      trailing: Text(
        '${order.total.toStringAsFixed(0)} ${'currency'.tr()}',
        style: TextStyle(color: gold, fontWeight: FontWeight.w800),
      ),
    );
  }
}
