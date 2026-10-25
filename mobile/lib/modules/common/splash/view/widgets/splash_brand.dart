import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/app_logo.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../../../../core/utils/functions/store_name.dart';

class SplashBrand extends StatelessWidget {
  const SplashBrand({
    super.key,
    required this.logoController,
    required this.textController,
  });

  final AnimationController logoController;
  final AnimationController textController;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final onBand = m.onBand;
    final reduce = context.reduceMotion;
    final logoCurve = CurvedAnimation(
      parent: logoController,
      curve: AppCurves.easeOut,
    );
    final textCurve = CurvedAnimation(
      parent: textController,
      curve: AppCurves.easeOut,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: logoCurve,
            builder: (context, child) {
              final t = reduce ? 1.0 : logoCurve.value;
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.scale(scale: 0.88 + 0.12 * t, child: child),
              );
            },
            child: Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: m.accent.withValues(alpha: 0.7),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: AppLogo(
                height: 84,
                onDarkSurface: onBand != Maison.inkLight,
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: reduce ? const AlwaysStoppedAnimation(1) : textCurve,
            child: Column(
              children: [
                Text(
                  storeName(context),
                  textAlign: TextAlign.center,
                  style: displayStyle(size: 36, color: onBand),
                ),
                const SizedBox(height: 14),
                const GoldRule(width: 72, draw: true),
                const SizedBox(height: 14),
                Text(
                  'app_tagline'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: onBand.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
