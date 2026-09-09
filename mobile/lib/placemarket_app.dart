import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/app_controller/app_controller_cubit.dart';
import 'config/routing/app_router.dart';
import 'config/theme/dark_mode.dart';
import 'config/theme/light_mode.dart';
import 'core/models/color_model.dart';
import 'core/utils/constant/app_string.dart';
import 'core/utils/functions/service_locator.dart';

class PlaceMarketApp extends StatelessWidget {
  const PlaceMarketApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final AppColors _colors = AppColors.defaults;
  static final ThemeData _lightTheme = light(_colors);
  static final ThemeData _darkTheme = dark(_colors);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppControllerCubit>(
      create: (context) => sl.get<AppControllerCubit>()..initServices(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) {
          return BlocBuilder<AppControllerCubit, AppControllerState>(
            buildWhen: (prev, curr) => prev.themeMode != curr.themeMode,
            builder: (context, state) {
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                debugShowCheckedModeBanner: false,
                title: AppString.appName,
                theme: _lightTheme,
                darkTheme: _darkTheme,
                themeMode: state.themeMode,
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}
