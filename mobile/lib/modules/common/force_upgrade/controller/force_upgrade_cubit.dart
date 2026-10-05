import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/app_models.dart';
import '../../../../core/utils/functions/app_toast.dart';

part 'force_upgrade_state.dart';

class ForceUpgradeCubit extends Cubit<ForceUpgradeState> {
  ForceUpgradeCubit(AppVersionModel version)
      : super(ForceUpgradeState(version: version));

  Future<void> copyStoreUrl() async {
    final url = state.version.storeUrl;
    if (url.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url));
    AppToast('open_store');
  }
}
