import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../controller/profile_cubit.dart';

class ProfileAccountActions extends StatelessWidget {
  const ProfileAccountActions({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('cancel'.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        AppButton(
          onTap: () async {
            final ok = await _confirm(
              context,
              title: 'logout'.tr(),
              body: 'logout_confirm'.tr(),
              action: 'logout'.tr(),
            );
            if (ok && context.mounted) {
              await context.read<ProfileCubit>().logout();
            }
          },
          title: 'logout'.tr(),
          isOutlined: true,
        ),
        const SizedBox(height: 12),
        AppButton(
          onTap: () async {
            final ok = await _confirm(
              context,
              title: 'delete_account'.tr(),
              body: 'delete_account_confirm'.tr(),
              action: 'delete_account'.tr(),
            );
            if (ok && context.mounted) {
              await context.read<ProfileCubit>().deleteAccount();
            }
          },
          title: 'delete_account'.tr(),
          isOutlined: true,
        ),
      ],
    );
  }
}
