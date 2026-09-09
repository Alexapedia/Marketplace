import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/orders_cubit.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

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
    return BlocProvider(
      create: (_) => OrdersCubit()..loadOne(orderId),
      child: Scaffold(
        appBar: AppBar(title: Text('order_details'.tr())),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.detailStatus == RequestStatus.loading ||
                state.detailStatus == RequestStatus.init) {
              return const LoadingItem();
            }
            if (state.current == null) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () => context.read<OrdersCubit>().loadOne(orderId),
              );
            }
            final o = state.current!;
            final gold = Theme.of(context).extension<AppColors>()!.gold;
            final idx = _flow.indexOf(o.status);
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '#${o.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 16),
                ..._flow.asMap().entries.map((e) {
                  final done = idx >= e.key || o.status == e.value;
                  final rejected = o.status == 'rejected' || o.status == 'cancelled';
                  return ListTile(
                    leading: Icon(
                      done && !rejected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: done ? gold : Colors.grey,
                    ),
                    title: Text(statusLabel(e.value)),
                  );
                }),
                if (o.status == 'rejected' || o.status == 'cancelled')
                  ListTile(
                    leading: Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
                    title: Text(statusLabel(o.status)),
                  ),
                if (o.rejectionReason != null && o.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('rejection_reason'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(o.rejectionReason!),
                ],
                const Divider(height: 32),
                Text('${'total'.tr()}: ${o.total.toStringAsFixed(0)} ${'currency'.tr()}'),
                Text('${'payment_method'.tr()}: ${o.paymentMethod}'),
                if (o.address != null) Text('${'address'.tr()}: ${o.address!.line}'),
                const SizedBox(height: 16),
                ...o.items.map(
                  (i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(i.product?.name ?? i.productId),
                    trailing: Text('x${i.quantity}'),
                  ),
                ),
                if (o.status == 'pending') ...[
                  const SizedBox(height: 20),
                  AppButton(
                    onTap: () => context.read<OrdersCubit>().cancel(orderId),
                    title: 'cancel_order'.tr(),
                    isOutlined: true,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
