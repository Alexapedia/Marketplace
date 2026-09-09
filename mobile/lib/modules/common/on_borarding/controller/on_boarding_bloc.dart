import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/constant/storage_key.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/shared_preferance_utils.dart';

part 'on_boarding_state.dart';

class OnBoardingPageChanged {
  const OnBoardingPageChanged(this.page);
  final int page;
}

class OnBoardingBloc extends Cubit<OnBoardingState> {
  OnBoardingBloc() : super(const OnBoardingState()) {
    load();
  }

  final pageController = PageController();

  static List<OnboardingSlide> fallback = [
    OnboardingSlide(
      title: 'onboarding_1_title'.tr(),
      body: 'onboarding_1_body'.tr(),
      icon: 'discover',
    ),
    OnboardingSlide(
      title: 'onboarding_2_title'.tr(),
      body: 'onboarding_2_body'.tr(),
      icon: 'favorites',
    ),
    OnboardingSlide(
      title: 'onboarding_3_title'.tr(),
      body: 'onboarding_3_body'.tr(),
      icon: 'custom',
    ),
  ];

  List<OnboardingSlide> pages = fallback;

  Future<void> load() async {
    final response = await sl.get<ApiConsumer>().get(EndPoints.appConfig);
    response.fold((_) {}, (success) {
      final config = AppConfigModel.fromJson(success.response);
      if (config.onboarding.isNotEmpty) {
        pages = config.onboarding;
        emit(state.copyWith(tick: state.tick + 1));
      }
    });
  }

  void add(OnBoardingPageChanged event) {
    emit(state.copyWith(selectedPage: event.page));
  }

  Future<void> finish(BuildContext context, {bool login = false}) async {
    await PreferenceUtils.setBool(StorageKey.onboardingSeen, true);
    await sl.get<AppControllerCubit>().enterGuestMode();
    if (!context.mounted) return;
    RouterHandler.navigate(
      context,
      login ? AppRouterKeys.signIn : AppRouterKeys.navigatorBarScreen,
      routerType: RouterType.goName,
    );
  }

  @override
  Future<void> close() {
    pageController.dispose();
    return super.close();
  }
}
