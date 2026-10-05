import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../connection/concept/end_points.dart';

class ImageItem extends StatelessWidget {
  const ImageItem(
    this.img, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
    this.heroTag,
  });

  final String img;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;
  final Object? heroTag;

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
    return child;
  }

  Widget _build(BuildContext context) {
    if (_isEmpty) return _fallback(context);
    if (_isAsset) {
      return _isSvg
          ? SvgPicture.asset(_src, width: width, height: height, fit: fit ?? BoxFit.contain)
          : Image.asset(_src, width: width, height: height, fit: fit, errorBuilder: (_, _, _) => _fallback(context));
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
        placeholder: (_, _) => _shimmer(context),
        errorWidget: (_, _, _) => _fallback(context),
      );
    }
    return _fallback(context);
  }

  Widget _shimmer(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
    child: SizedBox(width: width, height: height),
  );

  Widget _fallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.storefront_outlined,
        color: Theme.of(context).colorScheme.secondary,
        size: 32,
      ),
    );
  }
}
