import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/app_controller/app_controller_cubit.dart';

/// The store's display name from the app config, or the bundled `app_name`
/// before the config has loaded (and in isolated previews).
String storeName(BuildContext context) {
  var name = '';
  try {
    name = context.select<AppControllerCubit, String>((c) => c.state.brandName);
  } catch (_) {
    // No app controller above: bundled name only.
  }
  return name.trim().isNotEmpty ? name.trim() : 'app_name'.tr();
}
