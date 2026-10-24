import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/maison.dart';
import '../../controller/notifications_cubit.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final custom = (item.type ?? '').contains('custom');
    return SurfaceCard(
      elevated: false,
      color: item.isRead ? m.surface : m.accentSoft,
      padding: const EdgeInsets.all(14),
      onTap: () {
        context.read<NotificationsCubit>().markRead(item.id);
        final orderId = '${item.data['orderId'] ?? ''}';
        final customId = '${item.data['customOrderId'] ?? ''}';
        if (custom && customId.isNotEmpty) {
          context.pushNamed(AppRouterKeys.customOrderDetails, extra: customId);
        } else if (orderId.isNotEmpty) {
          context.pushNamed(AppRouterKeys.orderDetails, extra: orderId);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.isRead ? m.surface2 : m.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              custom
                  ? Icons.auto_awesome_outlined
                  : (item.isRead
                        ? Icons.notifications_none_rounded
                        : Icons.local_shipping_outlined),
              color: item.isRead ? m.inkMuted : m.onAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(
                    color: m.ink,
                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: m.inkMuted),
                ),
              ],
            ),
          ),
          if (!item.isRead)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8, top: 6),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: m.accentInk,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
