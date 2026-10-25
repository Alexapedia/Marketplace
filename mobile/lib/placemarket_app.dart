import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/app_controller/app_controller_cubit.dart';
import 'config/routing/app_router.dart';
import 'config/theme/dark_mode.dart';
import 'config/theme/light_mode.dart';
import 'core/models/color_model.dart';
import 'core/utils/constant/app_string.dart';
import 'core/utils/functions/color_convert.dart';
import 'core/utils/functions/responsive.dart';
import 'core/utils/functions/service_locator.dart';

class PlaceMarketApp extends StatelessWidget {
  const PlaceMarketApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final Map<String, ThemeData> _themes = {};

  /// Maison themes with the tenant's brand colours (primary = deep band,
  /// accent = "the light"). Text on brand fills is computed in [Maison].
  static ThemeData _theme(bool isDark, String primary, String accent) {
    return _themes.putIfAbsent('$isDark|$primary|$accent', () {
      final overrides = <String, dynamic>{
        if (accent.isNotEmpty) ...{'gold': accent, 'pinkAccent': accent},
        if (!isDark && primary.isNotEmpty) ...{
          'primary': primary,
          'secondary': primary,
          'gradientStart': primary,
        },
        if (isDark && accent.isNotEmpty) ...{'gradientStart': accent, 'gradientEnd': accent},
      };
      return isDark
          ? dark(
              overrides.isEmpty
                  ? AppColors.darkDefaults
                  : AppColors.fromJson(overrides, dark: true),
              brandPrimary: primary.isEmpty ? null : primary.toColor(),
            )
          : light(overrides.isEmpty ? AppColors.lightDefaults : AppColors.fromJson(overrides));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppControllerCubit>(
      create: (context) => sl.get<AppControllerCubit>()
        ..restoreBrand()
        ..initServices(),
      child: screenUtilHandler(
        child: BlocBuilder<AppControllerCubit, AppControllerState>(
          buildWhen: (prev, curr) =>
              prev.themeMode != curr.themeMode ||
              prev.brandPrimary != curr.brandPrimary ||
              prev.brandAccent != curr.brandAccent ||
              prev.brandName != curr.brandName,
          builder: (context, state) {
            return MaterialApp.router(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              title: state.brandName.isNotEmpty
                  ? state.brandName
                  : AppString.appName,
              theme: _theme(false, state.brandPrimary, state.brandAccent),
              darkTheme: _theme(true, state.brandPrimary, state.brandAccent),
              themeMode: state.themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
