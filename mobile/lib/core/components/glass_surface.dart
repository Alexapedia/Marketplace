import 'dart:ui';

import 'package:flutter/material.dart';

/// "Liquid glass" chrome surface: blurred backdrop under a translucent
/// surface fill. Use for app chrome only (navigation, sticky bars), never for
/// content cards.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.elevated = false,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Adds a soft upward shadow (sticky CTA bars).
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // BackdropFilter expands to fill its constraints, so it lives in a
    // positioned layer and the child alone decides the surface's size.
    final glass = Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.82),
                  borderRadius: borderRadius,
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
    if (!elevated) return glass;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: glass,
    );
  }
}
