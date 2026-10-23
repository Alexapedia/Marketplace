import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_logo.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/ads_pager_cubit.dart';
import 'ads_carousel.dart';

class AdsPart extends StatelessWidget {
  const AdsPart({super.key, required this.ads});

  final List<BannerModel> ads;

  @override
  Widget build(BuildContext context) {
    if (ads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          height: context.byDevice(
            mobileLandscape: context.isLandscape ? 150.0 : 150.0,
            mobile: context.isLandscape ? 150.0 : 150.0,
            tablet: context.isLandscape ? 118.0 : 180.0,
            desktop: 200.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: context.maison.band,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppLogo(
                  height: 64,
                  onDarkSurface: context.maison.onBand != Maison.inkLight,
                ),
                const SizedBox(height: 16),
                const GoldRule(width: 72),
              ],
            ),
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => AdsPagerCubit(),
      child: AdsCarousel(ads: ads),
    );
  }
}
