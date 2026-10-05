import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/order_status_timeline.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/components/star_rating.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/status_label.dart';
import '../../controller/order_details_cubit.dart';
import 'order_info_card.dart';
import 'order_item_tile.dart';
import 'order_kv.dart';

class OrderDetailsBody extends StatelessWidget {
  const OrderDetailsBody({super.key, required this.order});

  final OrderModel order;

  static const _flow = [
    'pending',
    'accepted',
    'preparing',
    'ready',
    'out_for_delivery',
    'delivered',
    'completed',
  ];

  @override
  Widget build(BuildContext context) {
    final shortId =
        order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          '#$shortId',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 16),
        OrderStatusTimeline(
          status: order.status,
          steps: _flow,
          labelOf: statusLabel,
        ),
        const SizedBox(height: 20),
        OrderInfoCard(
          children: [
            OrderKv(
              label: 'total'.tr(),
              value: '${order.total.toStringAsFixed(0)} ${'currency'.tr()}',
            ),
            OrderKv(label: 'payment_method'.tr(), value: order.paymentMethod),
            if (order.address != null && order.address!.display.isNotEmpty)
              OrderKv(label: 'address'.tr(), value: order.address!.display),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'items'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...order.items.map((i) => OrderItemTile(item: i)),
        if (order.rejectionReason != null &&
            order.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'rejection_reason'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(order.rejectionReason!),
        ],
        if (order.status == 'pending') ...[
          const SizedBox(height: 20),
          AppButton(
            onTap: () => context.read<OrderDetailsCubit>().cancel(order.id),
            title: 'cancel_order'.tr(),
            isOutlined: true,
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'order_rating'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (order.rating > 0) ...[
          StarRating(value: order.rating, size: 22, showValue: true),
          if (order.ratingComment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(order.ratingComment),
          ],
        ] else if (order.canRate) ...[
          Text(
            'rate_order_products_hint'.tr(),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            onTap: () => showRateSheet(
              context: context,
              title: 'rate_order'.tr(),
              onSubmit: (rating, comment) => context
                  .read<OrderDetailsCubit>()
                  .rate(order.id, rating, comment),
            ),
            title: 'add_rating'.tr(),
          ),
        ] else
          Text('rate_order_hint'.tr()),
      ],
    );
  }
}
