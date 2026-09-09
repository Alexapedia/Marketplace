import 'package:flutter/material.dart';

class LoadingItem extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingItem({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 36,
        height: size ?? 36,
        child: CircularProgressIndicator(
          strokeWidth: 2.6,
          color: color ?? Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
