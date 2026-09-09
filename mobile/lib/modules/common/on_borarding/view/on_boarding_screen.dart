import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/models/color_model.dart';
import '../controller/on_boarding_bloc.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  IconData _icon(String key) {
    return switch (key) {
      'favorites' => Icons.favorite_rounded,
      'custom' => Icons.auto_awesome_rounded,
      _ => Icons.shopping_bag_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final bloc = context.read<OnBoardingBloc>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: colors.onboardingBG),
        child: SafeArea(
          child: BlocBuilder<OnBoardingBloc, OnBoardingState>(
            builder: (context, state) {
              final pages = bloc.pages;
              final last = state.selectedPage == pages.length - 1;
              return Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => bloc.finish(context),
                      child: Text(
                        'skip'.tr(),
                        style: TextStyle(color: colors.gold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: bloc.pageController,
                      itemCount: pages.length,
                      onPageChanged: (i) => bloc.add(OnBoardingPageChanged(i)),
                      itemBuilder: (context, i) {
                        final page = pages[i];
                        return Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.gold.withValues(alpha: 0.12),
                                  border: Border.all(color: colors.gold, width: 1.4),
                                ),
                                child: Icon(
                                  _icon(page.icon),
                                  size: 64,
                                  color: colors.gold,
                                ),
                              ).animate().scale(),
                              const SizedBox(height: 36),
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                page.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  height: 1.5,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SmoothPageIndicator(
                    controller: bloc.pageController,
                    count: pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colors.gold,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: AppButton(
                      onTap: () {
                        if (last) {
                          bloc.finish(context);
                        } else {
                          bloc.pageController.nextPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      title: last ? 'get_started'.tr() : 'next'.tr(),
                    ),
                  ),
                  TextButton(
                    onPressed: () => bloc.finish(context, login: true),
                    child: Text(
                      'onboarding_skip_login'.tr(),
                      style: TextStyle(color: colors.gold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
