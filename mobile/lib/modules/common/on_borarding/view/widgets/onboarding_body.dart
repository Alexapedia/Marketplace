import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_logo.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/on_boarding_bloc.dart';
import 'onboarding_slide_view.dart';

class OnboardingBody extends StatelessWidget {
  const OnboardingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final bloc = context.read<OnBoardingBloc>();
    final compact = context.isCompactHeight;
    return SafeArea(
      child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
        builder: (context, state) {
          final pages = bloc.pages;
          final last = state.selectedPage == pages.length - 1;
          return Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  24,
                  compact ? 4 : 8,
                  8,
                  0,
                ),
                child: Row(
                  children: [
                    AppLogo(height: compact ? 28 : 36),
                    const Spacer(),
                    TextButton(
                      onPressed: () => bloc.finish(context),
                      child: Text('skip'.tr()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: bloc.pageController,
                  itemCount: pages.length,
                  onPageChanged: (i) => bloc.add(OnBoardingPageChanged(i)),
                  itemBuilder: (context, i) =>
                      OnboardingSlideView(page: pages[i]),
                ),
              ),
              SmoothPageIndicator(
                controller: bloc.pageController,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: m.accent,
                  dotColor: m.inkMuted.withValues(alpha: 0.3),
                  dotHeight: 7,
                  dotWidth: 7,
                  expansionFactor: 3.2,
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, compact ? 12 : 24, 24, 8),
                    child: AppButton(
                      onTap: () {
                        if (last) {
                          bloc.finish(context);
                        } else {
                          bloc.pageController.nextPage(
                            duration: context.motion(AppDurations.base),
                            curve: AppCurves.easeOut,
                          );
                        }
                      },
                      title: last ? 'get_started'.tr() : 'next'.tr(),
                      size: Size(double.infinity, compact ? 46 : 54),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => bloc.finish(context, login: true),
                child: Text('onboarding_skip_login'.tr()),
              ),
              SizedBox(height: compact ? 4 : 12),
            ],
          );
        },
      ),
    );
  }
}
