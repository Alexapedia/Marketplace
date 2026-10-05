import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';

class ProfileGuest extends StatelessWidget {
  const ProfileGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'guest_profile_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        Text('guest_profile_body'.tr()),
        const SizedBox(height: 12),
        AppButton(
          onTap: () => context.pushNamed(AppRouterKeys.signIn),
          title: 'login'.tr(),
        ),
        const SizedBox(height: 8),
        AppButton(
          onTap: () => context.pushNamed(AppRouterKeys.signUp),
          title: 'register'.tr(),
          isOutlined: true,
        ),
      ],
    );
  }
}
