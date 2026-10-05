import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routing/app_router_keys.dart';
import '../models/app_models.dart';
import '../utils/functions/responsive.dart';
import 'image_item.dart';

class AdBannerTile extends StatelessWidget {
  const AdBannerTile({
    super.key,
    required this.ad,
    this.height,
    this.borderRadius = 20,
  });

  final BannerModel ad;
  final double? height;
  final double borderRadius;

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
    final h =
        height ??
        context.byDevice(
          mobileLandscape: 168.0,
          mobile: 168.0,
          tablet: 200.0,
          desktop: 228.0,
        );
    return Padding(
      padding: EdgeInsets.only(
        left: context.locale.languageCode == 'ar' ? 8.0 : 0.0,
        right: context.locale.languageCode == 'ar' ? 0.0 : 8.0,
      ),
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
                ImageItem(ad.image, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0x99000000), Color(0x00000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ad.title.isNotEmpty)
                        Text(
                          ad.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: context.font(18),
                          ),
                        ),
                      if (ad.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ad.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: context.font(13),
                          ),
                        ),
                      ],
                      if (context.isTablet || context.isDesktop) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFC9A45C),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              child: Text(
                                'shop'.tr(),
                                style: const TextStyle(
                                  color: Color(0xFF071345),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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
    );
  }
}
