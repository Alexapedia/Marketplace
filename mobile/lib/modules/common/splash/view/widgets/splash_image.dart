import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/connection/concept/end_points.dart';

/// The store's own splash image (`branding.splash`) filling the screen, or
/// [fallback] — the built-in splash — when there is none, while it loads, or
/// when it fails.
class SplashImage extends StatelessWidget {
  const SplashImage({super.key, required this.fallback});

  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    var splash = '';
    try {
      splash = context.select<AppControllerCubit, String>(
        (c) => c.state.brandSplash,
      );
    } catch (_) {
      // No app controller above (isolated previews): built-in splash only.
    }
    final url = EndPoints.media(splash);
    if (url.isEmpty) return fallback;
    return CachedNetworkImage(
      key: ValueKey('splash-$url'),
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
