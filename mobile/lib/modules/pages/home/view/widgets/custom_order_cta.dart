import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/require_auth.dart';

/// Bespoke invitation set on the deep brand band.
class CustomOrderCta extends StatelessWidget {
  const CustomOrderCta({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final onBand = m.onBand;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 4),
      child: Reveal(
        child: Container(
          decoration: BoxDecoration(
            color: m.band,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.one(m.brightness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Signature gold rule along the top edge.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        m.accent.withValues(alpha: 0),
                        m.accent,
                        m.accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('bespoke'.tr(), color: m.accent),
                    const SizedBox(height: 10),
                    Text(
                      'custom_order_cta_title'.tr(),
                      style: displayStyle(size: 24, color: onBand),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'custom_order_cta_body'.tr(),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: onBand.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Pressable(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () => requireAuth(
                          context,
                          () => context.pushNamed(AppRouterKeys.myCustomOrders),
                        ),
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: Text('start_custom_order'.tr()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
