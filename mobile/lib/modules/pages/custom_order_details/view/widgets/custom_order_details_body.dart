import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/custom_order_models.dart';
import 'proposal_card.dart';

class CustomOrderDetailsBody extends StatelessWidget {
  const CustomOrderDetailsBody({super.key, required this.order});

  final CustomOrderModel order;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return AdaptivePage(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Eyebrow(
            order.categoryName.isEmpty
                ? 'custom_order'.tr()
                : order.categoryName,
          ),
          const SizedBox(height: 10),
          Text(
            order.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: m.ink),
          ),
          const SizedBox(height: 16),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                )
                .toList(),
          ),
          MaisonSectionHeader(
            title: 'proposals'.tr(),
            padding: const EdgeInsetsDirectional.only(top: 28, bottom: 14),
          ),
          if (order.proposals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'no_proposals'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: m.inkMuted),
              ),
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
      ),
    );
  }
}
