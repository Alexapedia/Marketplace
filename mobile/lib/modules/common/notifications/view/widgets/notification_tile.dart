import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../controller/notifications_cubit.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return ListTile(
      onTap: () {
        context.read<NotificationsCubit>().markRead(item.id);
        final orderId = '${item.data['orderId'] ?? ''}';
        final customId = '${item.data['customOrderId'] ?? ''}';
        if ((item.type ?? '').contains('custom') && customId.isNotEmpty) {
          context.pushNamed(AppRouterKeys.customOrderDetails, extra: customId);
        } else if (orderId.isNotEmpty) {
          context.pushNamed(AppRouterKeys.orderDetails, extra: orderId);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          item.isRead
              ? Icons.notifications_none
              : Icons.local_shipping_outlined,
          color: gold,
          size: 20,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w800,
        ),
      ),
      subtitle: Text(
        item.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: item.isRead
          ? null
          : Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: gold, shape: BoxShape.circle),
            ),
    );
  }
}
