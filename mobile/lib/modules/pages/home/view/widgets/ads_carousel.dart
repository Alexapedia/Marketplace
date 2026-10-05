import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/ad_banner_tile.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/ads_pager_cubit.dart';

class AdsCarousel extends StatelessWidget {
  const AdsCarousel({super.key, required this.ads});

  final List<BannerModel> ads;

  @override
  Widget build(BuildContext context) {
    final pager = context.read<AdsPagerCubit>();
    pager.syncItemCount(ads.length);
    if (!pager.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) pager.setRunning(true);
      });
    }
    final height = context.byDevice(
      mobileLandscape: context.isLandscape ? 150.0 : 176.0,
      mobile: context.isLandscape ? 150.0 : 176.0,
      tablet: context.isLandscape ? 118.0 : 210.0,
      desktop: 236.0,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(16, context.isCompactHeight ? 8 : 16, 16, 8),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: PageView.builder(
               controller: pager.pageController,
              onPageChanged: (page) =>
                  pager.onPageChanged(page, fromUser: true),
              itemCount: ads.length,
              itemBuilder: (context, i) => AdBannerTile(
                ad: ads[i],
                height: height,
              ),
            ),
          ),
          if (ads.length > 1 && !context.isCompactHeight) ...[
            const SizedBox(height: 10),
            BlocBuilder<AdsPagerCubit, int>(
              builder: (context, current) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(ads.length, (i) {
                    final selected = current == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: selected ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
