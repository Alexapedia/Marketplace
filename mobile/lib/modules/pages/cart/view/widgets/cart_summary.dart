import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/constant/app_string.dart';

/// Order summary: a glass bottom bar on phones, a side panel on tablets.
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
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    String money(double v) => '${v.toStringAsFixed(0)} ${AppString.currency}';
    final content = SafeArea(
      top: false,
      child: Padding(
        padding: expand
            ? const EdgeInsets.fromLTRB(28, 32, 28, 28)
            : const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (expand) ...[
              Eyebrow('order_summary'.tr()),
              const SizedBox(height: 8),
              Text(
                'checkout'.tr(),
                style: displayStyle(size: 28, color: m.ink),
              ),
              const SizedBox(height: 12),
              const GoldRule(width: 48),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Icon(Icons.payments_outlined, size: 18, color: m.accentInk),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'cod'.tr(),
                    style: text.labelLarge?.copyWith(color: m.inkMuted),
                  ),
                ),
              ],
            ),
            SizedBox(height: expand ? 20 : 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  'total'.tr(),
                  style: text.titleMedium?.copyWith(color: m.ink),
                ),
                const Spacer(),
                AnimatedNumber(
                  value: total,
                  format: money,
                  style: text.headlineSmall?.copyWith(
                    fontFamily: kFontFamily,
                    fontFamilyFallback: const [],
                    fontVariations: const [],
                    fontWeight: FontWeight.w600,
                    color: m.accentInk,
                  ),
                ),
              ],
            ),
            SizedBox(height: expand ? 24 : 14),
            if (expand) const Spacer(),
            AppButton(
              onTap: canCheckout
                  ? () => context.pushNamed(AppRouterKeys.checkout)
                  : null,
              title: 'checkout'.tr(),
              icon: Icons.lock_outline_rounded,
            ),
          ],
        ),
      ),
    );
    // Side panel (tablet/desktop) keeps its own surface; the bottom bar is glass.
    if (expand) return content;
    return GlassSurface(elevated: true, child: content);
  }
}
