import 'package:flutter/material.dart';

import '../../config/theme/tokens.dart';
import '../models/color_model.dart';

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
    final colors = theme.extension<AppColors>() ?? AppColors.defaults;
    final gold = colors.gold;
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
                            ? Colors.white.withValues(alpha: 0.2)
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
    final colors = theme.extension<AppColors>() ?? AppColors.defaults;
    final gold = colors.gold;
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
                                  ? const Color(0xFF4A5AA8)
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
                          ? (onDark
                                ? Colors.white
                                : theme.colorScheme.onSurface)
                          : (onDark
                                ? const Color(0xFF9AA6DC)
                                : colors.navMuted),
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
