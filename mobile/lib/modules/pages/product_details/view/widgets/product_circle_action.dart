import 'package:flutter/material.dart';

class ProductCircleAction extends StatelessWidget {
  const ProductCircleAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
    );
  }
}
