import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/app_button.dart';
import '../../controller/profile_cubit.dart';

class ProfileAccountActions extends StatelessWidget {
  const ProfileAccountActions({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    bool destructive = false,
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
                style: destructive
                    ? TextButton.styleFrom(foregroundColor: ctx.maison.danger)
                    : null,
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
    final m = context.maison;
    return Column(
      children: [
        const SizedBox(height: 24),
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
          icon: Icons.logout_rounded,
          isOutlined: true,
        ),
        const SizedBox(height: 4),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: m.danger,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () async {
            final ok = await _confirm(
              context,
              title: 'delete_account'.tr(),
              body: 'delete_account_confirm'.tr(),
              action: 'delete_account'.tr(),
              destructive: true,
            );
            if (ok && context.mounted) {
              await context.read<ProfileCubit>().deleteAccount();
            }
          },
          child: Text('delete_account'.tr()),
        ),
      ],
    );
  }
}
