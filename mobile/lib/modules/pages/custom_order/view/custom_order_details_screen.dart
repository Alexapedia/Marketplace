import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../orders/controller/orders_cubit.dart';
import '../controller/custom_order_cubit.dart';

class CustomOrderDetailsScreen extends StatelessWidget {
  const CustomOrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomOrderDetailsCubit()..load(orderId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('custom_order'.tr()),
          actions: [
            IconButton(
              onPressed: () => context.pushNamed(AppRouterKeys.chat, extra: orderId),
              icon: const Icon(Icons.chat_bubble_outline),
            ),
          ],
        ),
        body: BlocBuilder<CustomOrderDetailsCubit, CustomOrderDetailsState>(
          builder: (context, state) {
            if (state.status == RequestStatus.loading) return const LoadingItem();
            if (state.order == null) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () =>
                    context.read<CustomOrderDetailsCubit>().load(orderId),
              );
            }
            final o = state.order!;
            final gold = Theme.of(context).extension<AppColors>()!.gold;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(statusLabel(o.status), style: TextStyle(color: gold, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 8),
                Text(o.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: o.images
                      .map((e) => ImageItem(e, width: 88, height: 88, fit: BoxFit.cover, borderRadius: BorderRadius.circular(12)))
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text('proposals'.tr(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                if (o.proposals.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('no_proposals'.tr()),
                  ),
                ...o.proposals.map(
                  (p) => Card(
                    margin: const EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'proposal_price'.tr()}: ${p.price.toStringAsFixed(0)} ${'currency'.tr()}',
                            style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                          ),
                          if (p.notes.isNotEmpty) Text(p.notes),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  onTap: () => context
                                      .read<CustomOrderDetailsCubit>()
                                      .confirm(orderId, p.id),
                                  title: 'confirm_proposal'.tr(),
                                  size: const Size.fromHeight(44),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  isOutlined: true,
                                  onTap: () async {
                                    final ctrl = TextEditingController();
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text('reject_proposal'.tr()),
                                        content: AppTextField(
                                          controller: ctrl,
                                          title: 'reject_reason'.tr(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text('cancel'.tr()),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text('confirm'.tr()),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true && context.mounted) {
                                      context.read<CustomOrderDetailsCubit>().reject(
                                            orderId,
                                            p.id,
                                            ctrl.text,
                                          );
                                    }
                                  },
                                  title: 'reject_proposal'.tr(),
                                  size: const Size.fromHeight(44),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  onTap: () => context.pushNamed(AppRouterKeys.chat, extra: orderId),
                  title: 'chat'.tr(),
                  isOutlined: true,
                  icon: Icons.chat_outlined,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
