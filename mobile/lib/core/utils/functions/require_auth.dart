import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../config/app_controller/app_controller_cubit.dart';
import '../../../config/routing/app_router_keys.dart';
import '../../components/app_button.dart';
import '../../repository/package_handler/router_handler.dart';
import '../constant/app_enum.dart';
import 'service_locator.dart';

void requireAuth(BuildContext context, VoidCallback action) {
  if (!sl.get<AppControllerCubit>().state.isGuest) {
    action();
    return;
  }
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _GuestPromptSheet(),
  );
}

class _GuestPromptSheet extends StatelessWidget {
  const _GuestPromptSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary, const Color(0xFFC6A667)],
              ),
            ),
            child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            'login_required'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'login_required_desc'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            onTap: () {
              Navigator.of(context).pop();
              RouterHandler.navigate(
                context,
                AppRouterKeys.signIn,
                routerType: RouterType.pushName,
              );
            },
            title: 'login'.tr(),
          ),
          const SizedBox(height: 12),
          AppButton(
            onTap: () {
              Navigator.of(context).pop();
              RouterHandler.navigate(
                context,
                AppRouterKeys.signUp,
                routerType: RouterType.pushName,
              );
            },
            title: 'register'.tr(),
            isOutlined: true,
          ),
        ],
      ),
    );
  }
}
