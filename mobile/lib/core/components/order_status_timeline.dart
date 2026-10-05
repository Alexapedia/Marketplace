import 'package:flutter/material.dart';

import '../models/color_model.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.status,
    required this.steps,
    required this.labelOf,
  });

  final String status;
  final List<String> steps;
  final String Function(String) labelOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navy = theme.colorScheme.primary;
    final gold = theme.extension<AppColors>()?.gold ?? const Color(0xFFC9A45C);
    final rejected = status == 'rejected' || status == 'cancelled';
    final idx = steps.indexOf(status);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.18)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _Step(
                label: labelOf(steps[i]),
                done: !rejected && idx > i,
                current: !rejected && idx == i,
                failed: rejected && steps[i] == status,
                color: navy,
                accent: gold,
              ),
              if (i != steps.length - 1)
                Container(
                  width: 22,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  color: !rejected && idx > i
                      ? navy
                      : theme.colorScheme.outline.withValues(alpha: 0.35),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.done,
    required this.current,
    required this.failed,
    required this.color,
    required this.accent,
  });

  final String label;
  final bool done;
  final bool current;
  final bool failed;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final fill = failed
        ? Theme.of(context).colorScheme.error
        : current
            ? accent
            : done
                ? color
                : Colors.transparent;
    final border = failed
        ? Theme.of(context).colorScheme.error
        : current
            ? accent
            : done
                ? color
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.45);
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 2),
            ),
            child: (failed || done)
                ? Icon(
                    failed ? Icons.close : Icons.check,
                    size: 11,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: current || done ? FontWeight.w800 : FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
