import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/app_controller/app_controller_cubit.dart';
import '../connection/concept/end_points.dart';
import '../utils/constant/app_string.dart';
import '../utils/functions/store_name.dart';

/// The store's logo: the tenant logo from the app config when one is set
/// (`logoDark` on dark surfaces when present, else `logo`), otherwise — or
/// when the network image fails — the bundled mark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 64, this.width, this.onDarkSurface});

  final double height;
  final double? width;

  /// `true` forces the dark-surface mark (navy/dark surfaces).
  /// `false` forces the light-surface mark.
  /// `null` follows the current theme brightness.
  final bool? onDarkSurface;

  static bool _darkSurface(BuildContext context, bool? onDarkSurface) =>
      onDarkSurface ?? Theme.of(context).brightness == Brightness.dark;

  static String assetFor(BuildContext context, {bool? onDarkSurface}) =>
      _darkSurface(context, onDarkSurface)
      ? AppString.logoDark
      : AppString.logoLight;

  /// Network logo URL for this surface, or '' when the store has none.
  static String networkFor({
    required bool darkSurface,
    required String logo,
    required String logoDark,
  }) {
    final pick = darkSurface && logoDark.trim().isNotEmpty ? logoDark : logo;
    return EndPoints.media(pick);
  }

  @override
  Widget build(BuildContext context) {
    final dark = _darkSurface(context, onDarkSurface);
    var logos = ('', '');
    try {
      logos = context.select<AppControllerCubit, (String, String)>(
        (c) => (c.state.brandLogo, c.state.brandLogoDark),
      );
    } catch (_) {
      // No app controller above (isolated previews): bundled mark only.
    }
    final asset = Image.asset(
      assetFor(context, onDarkSurface: onDarkSurface),
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: storeName(context),
    );
    final url = networkFor(
      darkSurface: dark,
      logo: logos.$1,
      logoDark: logos.$2,
    );
    if (url.isEmpty) return asset;
    return Semantics(
      image: true,
      label: storeName(context),
      child: ExcludeSemantics(
        child: CachedNetworkImage(
          key: ValueKey('app-logo-$url'),
          imageUrl: url,
          height: height,
          width: width,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          fadeInDuration: const Duration(milliseconds: 200),
          placeholder: (_, _) => SizedBox(height: height, width: width),
          errorWidget: (_, _, _) => asset,
        ),
      ),
    );
  }
}
