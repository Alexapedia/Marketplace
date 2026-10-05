part of 'splash_cubit.dart';

mixin SplashBootMixin on Cubit<SplashState> {
  Future<void> boot(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!context.mounted) return;
    final force = await _checkForceUpgrade();
    if (!context.mounted) return;
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
    await sl<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.accessToken,
    );
    if (!context.mounted) return;
    RouterHandler.navigate(
      context,
      AppRouterKeys.navigatorBarScreen,
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
        if (isVersionBelow(info.version, model.minimumVersion) && model.force) {
          return model;
        }
        return null;
      });
    } catch (_) {
      return null;
    }
  }
}
