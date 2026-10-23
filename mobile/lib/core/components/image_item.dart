import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../connection/concept/end_points.dart';
import '../utils/functions/motion.dart';

class ImageItem extends StatelessWidget {
  const ImageItem(
    this.img, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.heroTag,
    this.semanticLabel,
  });

  final String img;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Object? heroTag;

  /// Accessible description; when null the image is treated as decorative.
  final String? semanticLabel;

  String get _src => EndPoints.media(img);
  bool get _isEmpty => _src.trim().isEmpty;
  bool get _isSvg => _src.toLowerCase().endsWith('.svg');
  bool get _isNetwork =>
      _src.startsWith('http://') || _src.startsWith('https://');
  bool get _isAsset => _src.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child = _build(context);
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius!, child: child);
    }
    if (heroTag != null) {
      child = Hero(tag: heroTag!, child: child);
    }
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: child);
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: child),
    );
  }

  Widget _build(BuildContext context) {
    if (_isEmpty) return _fallback(context);
    if (_isAsset) {
      return _isSvg
          ? SvgPicture.asset(
              _src,
              width: width,
              height: height,
              fit: fit ?? BoxFit.contain,
            )
          : Image.asset(
              _src,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (_, _, _) => _fallback(context),
            );
    }
    if (_isNetwork) {
      if (_isSvg) {
        return SvgPicture.network(
          _src,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          placeholderBuilder: (_) => _shimmer(context),
        );
      }
      return CachedNetworkImage(
        imageUrl: _src,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: (width != null && width!.isFinite)
            ? (width! * MediaQuery.devicePixelRatioOf(context)).round()
            : null,
        placeholder: (_, _) => _shimmer(context),
        errorWidget: (_, _, _) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _shimmer(BuildContext context) =>
      ImageShimmer(width: width, height: height);

  double get _fallbackSize {
    final w = width, h = height;
    if (w == null || h == null || !w.isFinite || !h.isFinite) return 32;
    return (math.min(w, h) * 0.35).clamp(20.0, 48.0);
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.storefront_outlined,
        color: Theme.of(context).colorScheme.secondary,
        size: _fallbackSize,
      ),
    );
  }
}

/// Looping loading placeholder; static under reduce-motion.
@visibleForTesting
class ImageShimmer extends StatefulWidget {
  const ImageShimmer({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<ImageShimmer> createState() => ImageShimmerState();
}

class ImageShimmerState extends State<ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _reduce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduce = context.reduceMotion;
    if (_reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final hi = scheme.surface;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _reduce ? 0.0 : _c.value;
        return DecoratedBox(
          key: const ValueKey('image-shimmer'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * t, 0),
              end: Alignment(-0.5 + 3 * t, 0),
              colors: [base, hi, base],
            ),
          ),
          child: SizedBox(width: widget.width, height: widget.height),
        );
      },
    );
  }
}
