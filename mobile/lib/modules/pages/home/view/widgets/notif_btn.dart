import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/utils/functions/require_auth.dart';

class NotifBtn extends StatelessWidget {
  const NotifBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => requireAuth(
        context,
        () => context.pushNamed(AppRouterKeys.notificationScreen),
      ),
      icon: BlocBuilder<AppControllerCubit, AppControllerState>(
        builder: (context, state) {
          return badges.Badge(
            showBadge: state.countOfUnReadNot > 0,
            badgeContent: Text(
              '${state.countOfUnReadNot}',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            child: const Icon(Icons.notifications_none_rounded),
          );
        },
      ),
    );
  }
}
