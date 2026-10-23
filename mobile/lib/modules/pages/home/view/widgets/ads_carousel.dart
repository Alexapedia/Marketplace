import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/ad_banner_tile.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/ads_pager_cubit.dart';

class AdsCarousel extends StatelessWidget {
  const AdsCarousel({super.key, required this.ads});

  final List<BannerModel> ads;

  @override
  Widget build(BuildContext context) {
    final pager = context.read<AdsPagerCubit>();
    pager.syncItemCount(ads.length);
    if (!pager.isRunning && !context.reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) pager.setRunning(true);
      });
    }
    final height = context.byDevice(
      mobileLandscape: context.isLandscape ? 200.0 : 300.0,
      mobile: context.isLandscape ? 200.0 : 300.0,
      tablet: context.isLandscape ? 300.0 : 360.0,
      desktop: 380.0,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(16, context.isCompactHeight ? 8 : 16, 16, 8),
      child: Column(
        children: [
          SizedBox(
            height: height,
            child: Stack(
              children: [
                PageView.builder(
                  controller: pager.pageController,
                  onPageChanged: (page) =>
                      pager.onPageChanged(page, fromUser: true),
                  itemCount: ads.length,
                  itemBuilder: (context, i) => AdBannerTile(
                    ad: ads[i],
                    height: height,
                    kenBurns: ads.length == 1,
                  ),
                ),
                if (ads.length > 1)
                  PositionedDirectional(
                    top: 8,
                    end: 16,
                    child: _PauseButton(pager: pager),
                  ),
              ],
            ),
          ),
          if (ads.length > 1 && !context.isCompactHeight) ...[
            BlocBuilder<AdsPagerCubit, int>(
              builder: (context, current) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(ads.length, (i) {
                    final selected = current == i;
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: 'a11y_go_to_slide'.tr(
                        args: ['${i + 1}', '${ads.length}'],
                      ),
                      excludeSemantics: true,
                      child: InkResponse(
                        onTap: () => pager.pageController.animateToPage(
                          i,
                          duration: context.motion(AppDurations.base),
                          curve: AppCurves.standard,
                        ),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: AnimatedContainer(
                              duration: context.motion(AppDurations.base),
                              curve: AppCurves.easeOut,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: selected ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: selected
                                    ? context.maison.accentInk
                                    : context.maison.inkMuted.withValues(
                                        alpha: 0.3,
                                      ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
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

class _PauseButton extends StatefulWidget {
  const _PauseButton({required this.pager});

  final AdsPagerCubit pager;

  @override
  State<_PauseButton> createState() => _PauseButtonState();
}

class _PauseButtonState extends State<_PauseButton> {
  @override
  void initState() {
    super.initState();
    // The carousel starts the pager in a post-frame callback; resync after it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final running = widget.pager.isRunning;
    return Semantics(
      button: true,
      label: running
          ? 'a11y_carousel_playing'.tr()
          : 'a11y_carousel_paused'.tr(),
      excludeSemantics: true,
      child: IconButton(
        key: const ValueKey('carousel-pause'),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.28),
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
        ),
        onPressed: () {
          widget.pager.setRunning(!running);
          setState(() {});
        },
        icon: Icon(
          running ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 20,
        ),
      ),
    );
  }
}
