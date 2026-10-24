import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routing/app_router_keys.dart';
import '../models/app_models.dart';
import '../utils/functions/responsive.dart';
import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../../config/theme/typography.dart';
import '../utils/functions/motion.dart';
import 'image_item.dart';
import 'maison.dart';

class AdBannerTile extends StatelessWidget {
  const AdBannerTile({
    super.key,
    required this.ad,
    this.height,
    this.borderRadius = 20,
    this.kenBurns = false,
  });

  final BannerModel ad;
  final double? height;
  final double borderRadius;

  /// Slow drift on the image; used for a standing hero (a single slide)
  /// where the carousel itself is not moving.
  final bool kenBurns;

  void _open(BuildContext context) {
    if (ad.productId != null && ad.productId!.isNotEmpty) {
      context.pushNamed(
        AppRouterKeys.productDetails,
        extra: {'id': ad.productId},
      );
      return;
    }
    if (ad.categoryId != null && ad.categoryId!.isNotEmpty) {
      context.pushNamed(
        AppRouterKeys.products,
        extra: {'categoryId': ad.categoryId, 'title': ad.title},
      );
      return;
    }
    if (ad.link != null && ad.link!.contains('newArrival')) {
      context.pushNamed(
        AppRouterKeys.products,
        extra: {
          'query': {'newArrival': true},
          'title': ad.title,
        },
      );
    } else if (ad.link != null && ad.link!.contains('featured')) {
      context.pushNamed(
        AppRouterKeys.products,
        extra: {
          'query': {'featured': true},
          'title': ad.title,
        },
      );
    } else if (ad.link != null && ad.link!.isNotEmpty) {
      context.pushNamed(AppRouterKeys.products, extra: {'title': ad.title});
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final double h =
        height ??
        context.byDevice<double>(
          mobileLandscape: 168.0,
          mobile: 200.0,
          tablet: 240.0,
          desktop: 260.0,
        );
    final big = h >= 260;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        button: true,
        label: ad.title.isEmpty ? null : ad.title,
        child: Pressable(
          child: GestureDetector(
            onTap: () => _open(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: SizedBox(
                height: h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: m.band),
                    kenBurns
                        ? KenBurns(
                            child: ImageItem(ad.image, fit: BoxFit.cover),
                          )
                        : ImageItem(ad.image, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: [0, 0.55, 1],
                          colors: [
                            Color(0xB3000000),
                            Color(0x33000000),
                            Color(0x00000000),
                          ],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: big ? 28 : 20,
                      end: big ? 28 : 20,
                      bottom: big ? 28 : 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Eyebrow('the_edit'.tr(), color: m.accent),
                          const SizedBox(height: 8),
                          if (ad.title.isNotEmpty)
                            Text(
                              ad.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: displayStyle(
                                size: big ? 36 : 28,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          if (ad.subtitle.isNotEmpty && h >= 180) ...[
                            const SizedBox(height: 6),
                            Text(
                              ad.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.86),
                                  ),
                            ),
                          ],
                          if (h >= 190) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: m.accent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'shop_now'.tr(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: m.onAccent),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: m.onAccent,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Slow 18s Ken Burns drift (scale 1 -> 1.08), once per appearance so the
/// frame settles. Static under reduced motion.
class KenBurns extends StatefulWidget {
  const KenBurns({super.key, required this.child});
  final Widget child;

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _c.stop();
      _c.value = 0;
    } else if (!_c.isAnimating) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.scale(
        scale: 1 + 0.08 * AppCurves.inOut.transform(_c.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
