import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../utils/functions/motion.dart';

/// Skeletonizer with the warm Maison shimmer from the theme; under reduced
/// motion the shimmer becomes a static warm fill.
class MaisonSkeleton extends StatelessWidget {
  const MaisonSkeleton({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: context.reduceMotion
          ? SolidColorEffect(color: context.maison.surface2)
          : null,
      child: child,
    );
  }
}

/// Card-shaped list placeholders for list screens while the first page loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 96,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return MaisonSkeleton(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, _) => Container(
          height: itemHeight,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: m.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: m.line),
          ),
          child: Row(
            children: [
              Bone.square(
                size: 64,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Bone.text(words: 3),
                    SizedBox(height: AppSpacing.xs),
                    Bone.text(words: 5, fontSize: 12),
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

/// Detail-screen placeholder: an optional hero block followed by text lines
/// shaped like the product page ([heroHeight] 0 = no hero block).
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key, this.heroHeight = 220});

  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    return MaisonSkeleton(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          if (heroHeight > 0) ...[
            Bone(
              height: heroHeight,
              width: double.infinity,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          const Bone.text(words: 1, fontSize: 12),
          const SizedBox(height: AppSpacing.sm),
          const Bone.text(words: 3, fontSize: 28),
          const SizedBox(height: AppSpacing.md),
          const Bone.text(words: 2, fontSize: 22),
          const SizedBox(height: AppSpacing.lg),
          const Bone.multiText(lines: 4),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Bone(
                    height: 76,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
