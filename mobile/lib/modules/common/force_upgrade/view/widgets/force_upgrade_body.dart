import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/models/color_model.dart';
import '../../controller/force_upgrade_cubit.dart';

class ForceUpgradeBody extends StatelessWidget {
  const ForceUpgradeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final version = context.watch<ForceUpgradeCubit>().state.version;
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.system_update_alt_rounded, size: 88, color: gold),
          const SizedBox(height: 24),
          Text(
            'force_upgrade_title'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            version.message.isNotEmpty
                ? version.message
                : 'force_upgrade_body'.tr(),
            textAlign: TextAlign.center,
          ),
          if (version.storeUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            SelectableText(
              version.storeUrl,
              textAlign: TextAlign.center,
              style: TextStyle(color: gold),
            ),
          ],
          const SizedBox(height: 32),
          AppButton(
            onTap: () => context.read<ForceUpgradeCubit>().copyStoreUrl(),
            title: 'update_now'.tr(),
          ),
        ],
      ),
    );
  }
}
