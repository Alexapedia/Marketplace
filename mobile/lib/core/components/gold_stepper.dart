import 'package:flutter/material.dart';

import '../models/color_model.dart';

class GoldBarStepper extends StatelessWidget {
  const GoldBarStepper({
    super.key,
    required this.total,
    required this.completed,
  });

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()?.gold ??
        const Color(0xFFC9A45C);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i < completed
                      ? gold
                      : Colors.white.withValues(alpha: 0.2),
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
  });

  final List<String> steps;
  final String current;
  final String Function(String) labelOf;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()?.gold ??
        const Color(0xFFC9A45C);
    final idx = steps.indexOf(current);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
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
                        color: idx >= i ? gold : const Color(0xFF4A5AA8),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labelOf(steps[i]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: idx >= i ? FontWeight.w700 : FontWeight.w400,
                      color: idx >= i ? Colors.white : const Color(0xFF9AA6DC),
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
