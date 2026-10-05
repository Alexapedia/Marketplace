import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/custom_order_models.dart';
import 'proposal_card.dart';

class CustomOrderDetailsBody extends StatelessWidget {
  const CustomOrderDetailsBody({super.key, required this.order});

  final CustomOrderModel order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(order.description),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: order.images
              .map(
                (e) => ImageItem(
                  e,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        if (order.proposals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('no_proposals'.tr()),
          ),
        ...order.proposals.map(
          (p) => ProposalCard(orderId: order.id, proposal: p),
        ),
        const SizedBox(height: 8),
        AppButton(
          onTap: () => context.pushNamed(AppRouterKeys.chat, extra: order.id),
          title: 'chat'.tr(),
          isOutlined: true,
          icon: Icons.chat_outlined,
        ),
      ],
    );
  }
}
