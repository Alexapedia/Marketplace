import 'package:flutter/material.dart';

import '../../config/theme/tokens.dart';
import '../../config/theme/maison.dart';

class GoldBarStepper extends StatelessWidget {
  const GoldBarStepper({
    super.key,
    required this.total,
    required this.completed,
    this.onDark = true,
  });

  /// True on the dark onboarding gradient; false uses theme colors.
  final bool onDark;

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = context.maison;
    final gold = m.accent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 10),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < completed
                      ? gold
                      : (onDark
                            ? m.onBand.withValues(alpha: 0.2)
                            : theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GoldDotStepper extends StatelessWidget {
  const GoldDotStepper({
    super.key,
    required this.steps,
    required this.current,
    required this.labelOf,
    this.onDark = true,
  });

  /// True on the dark onboarding gradient; false uses theme colors.
  final bool onDark;

  final List<String> steps;
  final String current;
  final String Function(String) labelOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = context.maison;
    final gold = m.accent;
    final idx = steps.indexOf(current);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xxs,
        AppSpacing.md,
        14,
      ),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: idx >= i ? gold : Colors.transparent,
                      border: Border.all(
                        color: idx >= i
                            ? gold
                            : (onDark
                                  ? m.onBand.withValues(alpha: 0.4)
                                  : theme.colorScheme.outlineVariant),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    labelOf(steps[i]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: idx >= i ? FontWeight.w700 : FontWeight.w400,
                      color: idx >= i
                          ? (onDark ? m.onBand : theme.colorScheme.onSurface)
                          : (onDark
                                ? m.onBand.withValues(alpha: 0.7)
                                : m.inkMuted),
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
