import 'package:easy_localization/easy_localization.dart';

import '../../../config/app_controller/app_controller_cubit.dart';
import '../functions/currency_label.dart';
import '../functions/service_locator.dart';

class AppString {
  static const String appName = 'Zezo Store';
  static const String localeEn = 'en';
  static const String localeAr = 'ar';
  static const String headerAcceptLanguage = 'Accept-Language';
  static const String headerAuthorization = 'Authorization';
  static const String requiresTokenKey = 'requiresToken';
  static const String jsonKeyToken = 'token';
  static const String jsonKeyAccessToken = 'accessToken';
  static const String jsonKeyAccess = 'access';
  static const String jsonKeyUser = 'user';
  static const String jsonKeyData = 'data';
  static const String jsonKeyMeta = 'meta';
  static const String jsonKeySuccess = 'success';
  static const String jsonKeyMessage = 'message';
  static const String jsonKeyId = 'id';
  static const String jsonKeyCount = 'count';
  static const String jsonKeyUnreadCount = 'unreadCount';
  static const String assetsDirPrefix = 'assets/';
  static const String logoLight = 'assets/images/logo.png';
  static const String logoDark = 'assets/images/logo_white.png';
  static const String unexpectedError = 'Unexpected error occurred';
  static const String error403Marker = '403';

  static String get currency {
    try {
      final state = sl.get<AppControllerCubit>().state;
      return currencyLabel(state.currency, state.localeCode);
    } catch (_) {
      return 'currency'.tr();
    }
  }
}
