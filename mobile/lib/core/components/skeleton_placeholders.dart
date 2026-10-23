import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../config/theme/tokens.dart';

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
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, _) => Card(
          child: SizedBox(
            height: itemHeight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  const Bone.square(size: 56),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Bone.text(words: 3),
                        SizedBox(height: AppSpacing.xs),
                        Bone.text(words: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Detail-screen placeholder: a hero block followed by text lines.
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key, this.heroHeight = 220});

  final double heroHeight;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Bone.square(
            size: heroHeight,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          const SizedBox(height: AppSpacing.md),
          const Bone.text(words: 4, fontSize: 22),
          const SizedBox(height: AppSpacing.sm),
          const Bone.text(words: 2),
          const SizedBox(height: AppSpacing.md),
          const Bone.multiText(lines: 4),
          const SizedBox(height: AppSpacing.md),
          const Bone.multiText(lines: 3),
        ],
      ),
    );
  }
}
