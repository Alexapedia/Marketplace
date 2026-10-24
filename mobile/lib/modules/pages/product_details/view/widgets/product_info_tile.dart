import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';

class ProductInfoTile extends StatelessWidget {
  const ProductInfoTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: m.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: m.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: m.accentInk),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(height: 1.35, color: m.ink),
            ),
          ],
        ),
      ),
    );
  }
}
