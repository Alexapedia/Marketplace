import 'package:flutter/material.dart';

class ProductCircleAction extends StatelessWidget {
  const ProductCircleAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
    );
  }
}
