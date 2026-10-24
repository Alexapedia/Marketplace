import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/require_auth.dart';

class NotifBtn extends StatelessWidget {
  const NotifBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppControllerCubit, AppControllerState, int>(
      selector: (s) => s.countOfUnReadNot,
      builder: (context, count) {
        return BumpBadge(
          count: count,
          child: IconButton(
            tooltip: 'a11y_notifications'.tr(),
            onPressed: () => requireAuth(
              context,
              () => context.pushNamed(AppRouterKeys.notificationScreen),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}
