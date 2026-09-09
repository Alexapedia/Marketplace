import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/app_controller/app_controller_cubit.dart';
import '../../../config/routing/app_router_keys.dart';
import '../../../placemarket_app.dart';
import '../../connection/concept/end_points.dart';
import '../../connection/interfaces/api_consumer.dart';
import '../../repository/package_handler/router_handler.dart';
import '../constant/app_enum.dart';
import '../constant/storage_key.dart';
import 'app_toast.dart';
import 'handle_multi_callback.dart';
import 'service_locator.dart';
import 'shared_preferance_utils.dart';

Future<void> logOut({String? msg, bool isUseLogoutApi = true}) async {
  final token = await sl.get<HandleMultiCallLocal>().getLocalData(
    keyType: LocalEnumKey.accessToken,
  );
  if (token != null && isUseLogoutApi) {
    try {
      await sl.get<ApiConsumer>().post(EndPoints.logout, body: {});
    } catch (_) {}
  }
  if (msg != null) AppToast(msg, isError: true);
  await const FlutterSecureStorage().deleteAll();
  await sl.get<HandleMultiCallLocal>().clear();
  await PreferenceUtils.setBool(StorageKey.isGuestMode, true);
  await sl.get<AppControllerCubit>().enterGuestMode();
  final context = PlaceMarketApp.navigatorKey.currentContext;
  if (context != null && context.mounted) {
    await RouterHandler.navigate(
      context,
      AppRouterKeys.signIn,
      routerType: RouterType.goName,
    );
  } else {
    AppToast('connection_error'.tr(), isError: true);
  }
}
