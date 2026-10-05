import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../controller/custom_orders_list_cubit.dart';
import 'custom_order_tile.dart';

class CustomOrdersListBody extends StatelessWidget {
  const CustomOrdersListBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    if (isGuest) {
      return EmptyState(
        title: 'login_required'.tr(),
        subtitle: 'login_required_desc'.tr(),
        icon: Icons.auto_awesome,
        action: AppButton(
          onTap: () => requireAuth(context, () {}),
          title: 'login'.tr(),
          size: const Size(220, 48),
        ),
      );
    }
    return BlocBuilder<CustomOrdersListCubit, CustomOrdersListState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(
            msg: state.error,
            onTapRefresh: () => context.read<CustomOrdersListCubit>().load(),
          );
        }
        if (state.status != RequestStatus.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.items.isEmpty) {
          return EmptyState(
            title: 'empty_custom_orders'.tr(),
            icon: Icons.auto_awesome,
            action: AppButton(
              onTap: () => context.pushNamed(AppRouterKeys.customOrder),
              title: 'start_custom_order'.tr(),
              size: const Size(220, 48),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: state.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => CustomOrderTile(order: state.items[i]),
        );
      },
    );
  }
}
