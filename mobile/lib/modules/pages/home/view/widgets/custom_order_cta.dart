import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../../../../core/utils/functions/responsive.dart';

class CustomOrderCta extends StatelessWidget {
  const CustomOrderCta({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: CustomPaint(
        painter: _DashedRRect(color: gold),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.byDevice(mobileLandscape: 12.0, mobile: 12.0, tablet: 16.0),
            vertical: 10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'custom_order_cta_title'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.font(13),
                    color: onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blackColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: () => requireAuth(
                  context,
                  () => context.pushNamed(AppRouterKeys.myCustomOrders),
                ),
                child: Text(
                  'custom_order'.tr(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRect extends CustomPainter {
  _DashedRRect({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromLTRBR(
      0.75,
      0.75,
      size.width - 0.75,
      size.height - 0.75,
      const Radius.circular(14),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRect oldDelegate) => oldDelegate.color != color;
}
