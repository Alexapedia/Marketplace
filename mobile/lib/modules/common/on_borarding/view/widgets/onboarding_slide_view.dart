import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/utils/functions/responsive.dart';

class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.page});

  final OnboardingSlide page;

  IconData get _icon => switch (page.icon) {
    'favorites' => Icons.favorite_border_rounded,
    'custom' => Icons.auto_awesome_outlined,
    _ => Icons.shopping_bag_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final compact = context.isCompactHeight || context.isLandscape;
    final markSize = compact
        ? 96.0
        : context.byDevice(
            mobileLandscape: 168.0,
            mobile: 168.0,
            tablet: 220.0,
            desktop: 240.0,
          );

    // Two concentric rings around the mark: hairline accent, then a soft well.
    final mark = Container(
      width: markSize + 28,
      height: markSize + 28,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: m.accent.withValues(alpha: 0.55)),
      ),
      child: ClipOval(
        child: page.image.isNotEmpty
            ? ImageItem(page.image, fit: BoxFit.cover)
            : ColoredBox(
                color: m.band,
                child: Icon(_icon, size: markSize * 0.4, color: m.accent),
              ),
      ),
    );

    final texts = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Reveal(
          index: 1,
          child: Text(
            page.title,
            textAlign: TextAlign.center,
            style: displayStyle(
              size: context.font(compact ? 26 : 34),
              color: m.ink,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const GoldRule(width: 56),
        SizedBox(height: compact ? 10 : 16),
        Reveal(
          index: 2,
          child: Text(
            page.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: m.inkMuted,
              fontSize: context.font(compact ? 14 : 16),
            ),
          ),
        ),
      ],
    );

    final content = compact
        ? Row(
            children: [
              Reveal(child: mark),
              const SizedBox(width: 28),
              Expanded(child: texts),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Reveal(child: mark),
              const SizedBox(height: 36),
              texts,
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.byDevice(
              mobileLandscape: 28.0,
              mobile: 28.0,
              tablet: 64.0,
            ),
            vertical: compact ? 8 : 28,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}
