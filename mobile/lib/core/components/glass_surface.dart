import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';

/// Saturation matrix (1.4) for the glass backdrop.
const List<double> _saturate14 = [
  1.2873, -0.2861, -0.0012, 0, 0, //
  -0.0427, 1.0439, -0.0012, 0, 0, //
  -0.0427, -0.2861, 1.3288, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// Maison glass chrome: surface at 72% over a blur(18) saturate(1.4)
/// backdrop with a hairline edge. App chrome only (navigation, sticky bars),
/// never content cards.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.elevated = false,
    this.edge = GlassEdge.top,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Adds a soft upward shadow (sticky CTA bars).
  final bool elevated;

  /// Where the hairline sits.
  final GlassEdge edge;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final side = BorderSide(color: m.line);
    final Border border = switch (edge) {
      GlassEdge.top => Border(top: side),
      GlassEdge.bottom => Border(bottom: side),
      GlassEdge.all => Border.all(color: m.line),
      GlassEdge.none => const Border(),
    };
    // BackdropFilter expands to fill its constraints, so it lives in a
    // positioned layer and the child alone decides the surface's size.
    final glass = Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.compose(
                outer: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                inner: const ColorFilter.matrix(_saturate14),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: m.glass,
                  borderRadius: borderRadius,
                  border: edge == GlassEdge.all ? border : null,
                ),
                position: DecorationPosition.background,
                child: edge == GlassEdge.all || edge == GlassEdge.none
                    ? const SizedBox.expand()
                    : DecoratedBox(
                        decoration: BoxDecoration(border: border),
                        child: const SizedBox.expand(),
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
        boxShadow: AppShadows.up(m.brightness),
      ),
      child: glass,
    );
  }
}

enum GlassEdge { top, bottom, all, none }
