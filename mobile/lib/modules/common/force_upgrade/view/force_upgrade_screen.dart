import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/functions/app_toast.dart';

class ForceUpgradeScreen extends StatelessWidget {
  const ForceUpgradeScreen({super.key, required this.version});

  final AppVersionModel version;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
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
                onTap: () async {
                  if (version.storeUrl.isEmpty) return;
                  await Clipboard.setData(
                    ClipboardData(text: version.storeUrl),
                  );
                  AppToast('open_store');
                },
                title: 'update_now'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
