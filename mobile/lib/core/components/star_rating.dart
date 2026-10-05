import 'package:flutter/material.dart';

import '../models/color_model.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.size = 16,
    this.onChanged,
    this.showValue = false,
    this.count,
  });

  final double value;
  final double size;
  final ValueChanged<double>? onChanged;
  final bool showValue;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()?.gold ??
        const Color(0xFFC9A45C);
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.22);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i.toDouble()),
            child: Padding(
              padding: EdgeInsets.only(right: size * 0.08),
              child: Icon(
                i <= value.round()
                    ? Icons.star_rounded
                    : (i - 0.5 <= value
                        ? Icons.star_half_rounded
                        : Icons.star_border_rounded),
                size: size,
                color: i - 0.5 <= value ? gold : muted,
              ),
            ),
          ),
        if (showValue) ...[
          const SizedBox(width: 4),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.78,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (count != null)
            Text(
              ' ($count)',
              style: TextStyle(
                fontSize: size * 0.7,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
        ],
      ],
    );
  }
}
