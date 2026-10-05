import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_string.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    super.key,
    required this.total,
    required this.canCheckout,
    this.expand = false,
  });

  final double total;
  final bool canCheckout;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<AppColors>()!.roseSoftLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '💵  ${'cod'.tr()}',
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('total'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                '${total.toStringAsFixed(0)} ${AppString.currency}',
                style: TextStyle(
                  color: gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (expand) const Spacer(),
          AppButton(
            onTap: canCheckout
                ? () => context.pushNamed(AppRouterKeys.checkout)
                : null,
            title: 'checkout'.tr(),
          ),
        ],
      ),
    );
  }
}
