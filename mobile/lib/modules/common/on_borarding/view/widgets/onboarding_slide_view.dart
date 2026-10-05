import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/responsive.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.page});

  final OnboardingSlide page;

  IconData get _icon => switch (page.icon) {
        'favorites' => Icons.favorite_rounded,
        'custom' => Icons.auto_awesome_rounded,
        _ => Icons.shopping_bag_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? AppColors.whiteColor : AppColors.blackColor;
    final compact = context.isCompactHeight || context.isLandscape;
    final iconSize = compact
        ? context.byDevice(mobileLandscape: 72.0, mobile: 72.0, tablet: 96.0, desktop: 110.0)
        : context.byDevice(mobileLandscape: 140.0, mobile: 140.0, tablet: 160.0, desktop: 180.0);
    final glyphSize = compact ? 36.0 : 64.0;

    final mark = page.image.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ImageItem(
              page.image,
              width: iconSize * 1.6,
              height: iconSize * 1.6,
              fit: BoxFit.cover,
            ),
          ).animate().fadeIn(duration: 280.ms)
        : Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.gold.withValues(alpha: 0.12),
              border: Border.all(color: colors.gold, width: 1.4),
            ),
            child: Icon(_icon, size: glyphSize, color: colors.gold),
          ).animate().fadeIn(duration: 280.ms);

    final texts = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface,
            fontSize: context.font(compact ? 22 : 28),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Text(
          page.body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.72),
            height: 1.5,
            fontSize: context.font(compact ? 13 : 15),
          ),
        ),
      ],
    );

    final content = compact
        ? Row(
            children: [
              mark,
              const SizedBox(width: 20),
              Expanded(child: texts),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              mark,
              const SizedBox(height: 28),
              texts,
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.byDevice(mobileLandscape: 24.0, mobile: 24.0, tablet: 40.0),
            vertical: compact ? 8 : 28,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}
