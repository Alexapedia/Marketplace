import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../controller/force_upgrade_cubit.dart';

class ForceUpgradeBody extends StatelessWidget {
  const ForceUpgradeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final version = context.watch<ForceUpgradeCubit>().state.version;
    final m = context.maison;
    return EmptyState(
      icon: Icons.system_update_alt_rounded,
      title: 'force_upgrade_title'.tr(),
      subtitle: version.message.isNotEmpty
          ? version.message
          : 'force_upgrade_body'.tr(),
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (version.storeUrl.isNotEmpty) ...[
            SelectableText(
              version.storeUrl,
              textAlign: TextAlign.center,
              style: TextStyle(color: m.accentInk),
            ),
            const SizedBox(height: 16),
          ],
          AppButton(
            onTap: () => context.read<ForceUpgradeCubit>().copyStoreUrl(),
            title: 'update_now'.tr(),
          ),
        ],
      ),
    );
  }
}
