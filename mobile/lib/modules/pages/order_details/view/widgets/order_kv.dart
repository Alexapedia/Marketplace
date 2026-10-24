import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';

class OrderKv extends StatelessWidget {
  const OrderKv({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: text.labelLarge?.copyWith(color: m.inkMuted),
            ),
          ),
          Expanded(
            child: Text(value, style: text.bodyMedium?.copyWith(color: m.ink)),
          ),
        ],
      ),
    );
  }
}
