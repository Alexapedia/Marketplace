import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';

/// The code the customer gives the courier on delivery; it completes the
/// order. Shown only while the order is still on its way.
class DeliveryCodeCard extends StatelessWidget {
  const DeliveryCodeCard({super.key, required this.order});

  final OrderModel order;

  static const _open = {
    'pending',
    'accepted',
    'preparing',
    'ready',
    'out_for_delivery',
  };

  static bool shownFor(OrderModel order) =>
      order.deliveryCode.trim().isNotEmpty && _open.contains(order.status);

  @override
  Widget build(BuildContext context) {
    if (!shownFor(order)) return const SizedBox.shrink();
    final code = order.deliveryCode.trim();
    final m = context.maison;
    return SizedBox(
      width: double.infinity,
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('delivery_code'.tr()),
            const SizedBox(height: 10),
            Semantics(
              label: code.split('').join(' '),
              child: ExcludeSemantics(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    code,
                    style: displayStyle(
                      size: 34,
                      color: m.ink,
                    ).copyWith(letterSpacing: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'delivery_code_hint'.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: m.inkMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
