import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/maison.dart';

class ProfileGuest extends StatelessWidget {
  const ProfileGuest({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SurfaceCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'guest_profile_title'.tr(),
              style: text.titleMedium?.copyWith(color: m.ink),
            ),
            const SizedBox(height: 6),
            Text(
              'guest_profile_body'.tr(),
              style: text.bodyMedium?.copyWith(color: m.inkMuted),
            ),
            const SizedBox(height: 18),
            AppButton(
              onTap: () => context.pushNamed(AppRouterKeys.signIn),
              title: 'login'.tr(),
            ),
            const SizedBox(height: 10),
            AppButton(
              onTap: () => context.pushNamed(AppRouterKeys.signUp),
              title: 'register'.tr(),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
