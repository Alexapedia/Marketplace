import 'package:flutter/material.dart';

import '../../../../../core/components/maison.dart';

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
  Widget build(BuildContext context) => GlassCircleButton(
    icon: icon,
    onPressed: onTap,
    tooltip: tooltip,
    color: color,
  );
}
