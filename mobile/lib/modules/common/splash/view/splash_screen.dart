import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/components/app_logo.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/constant/storage_key.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/shared_preferance_utils.dart';
import '../../../../core/utils/functions/version_compare.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _textController.forward();
    });
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    final force = await _checkForceUpgrade();
    if (!mounted) return;
    if (force != null) {
      RouterHandler.navigate(
        context,
        AppRouterKeys.forceUpgrade,
        routerType: RouterType.goName,
        extra: force,
      );
      return;
    }
    final seen = PreferenceUtils.getBool(StorageKey.onboardingSeen);
    if (!seen) {
      RouterHandler.navigate(
        context,
        AppRouterKeys.onBoarding,
        routerType: RouterType.goName,
      );
      return;
    }
    final token = await sl<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.accessToken,
    );
    if (!mounted) return;
    RouterHandler.navigate(
      context,
      (token != null && token.isNotEmpty)
          ? AppRouterKeys.navigatorBarScreen
          : AppRouterKeys.navigatorBarScreen,
      routerType: RouterType.goName,
    );
  }

  Future<AppVersionModel?> _checkForceUpgrade() async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await sl.get<ApiConsumer>().get(
        EndPoints.appVersion,
        queryParameters: {'platform': platform},
      );
      return await response.fold((_) => null, (success) async {
        final model = AppVersionModel.fromJson(success.response);
        if (model.minimumVersion.isEmpty) return null;
        final info = await PackageInfo.fromPlatform();
        if (isVersionBelow(info.version, model.minimumVersion) &&
            model.force) {
          return model;
        }
        return null;
      });
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.blackColor : AppColors.whiteColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                final curve = CurvedAnimation(
                  parent: _logoController,
                  curve: Curves.elasticOut,
                );
                return Transform.scale(
                  scale: curve.value.clamp(0.0, 1.0),
                  child: child,
                );
              },
              child: const AppLogo(height: 148),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _textController,
              child: Column(
                children: [
                  Text(
                    'app_name'.tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.whiteColor
                          : AppColors.blackColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'app_tagline'.tr(),
                    style: TextStyle(
                      color: (isDark
                              ? AppColors.whiteColor
                              : AppColors.blackColor)
                          .withValues(alpha: 0.72),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
