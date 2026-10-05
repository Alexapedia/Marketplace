import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/review_card.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../controller/profile_cubit.dart';
import 'profile_tile.dart';
import 'support_sheet.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key, required this.state});

  final AppControllerState state;

  @override
  Widget build(BuildContext context) {
    final arrow = Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
    return Column(
      children: [
        _navTile(
          context,
          icon: Icons.person_outline,
          title: 'edit_profile'.tr(),
          trailing: arrow,
          onTap: () => context.pushNamed(AppRouterKeys.editProfile),
        ),
        _navTile(
          context,
          icon: Icons.favorite_border,
          title: 'favorites'.tr(),
          trailing: arrow,
          onTap: () => requireAuth(
            context,
            () => context.pushNamed(AppRouterKeys.favorites),
          ),
        ),
        _navTile(
          context,
          icon: Icons.location_on_outlined,
          title: 'my_addresses'.tr(),
          trailing: arrow,
          onTap: () => requireAuth(
            context,
            () => context.pushNamed(AppRouterKeys.addresses),
          ),
        ),
        if (state.supportPhone.isNotEmpty || state.supportEmail.isNotEmpty)
          _navTile(
            context,
            icon: Icons.support_agent,
            title: 'support'.tr(),
            trailing: arrow,
            onTap: () => SupportSheet.show(
              context,
              phone: state.supportPhone,
              email: state.supportEmail,
            ),
          ),
        _navTile(
          context,
          icon: Icons.star_rate_rounded,
          title: 'rate_app'.tr(),
          trailing: arrow,
          onTap: () => showRateSheet(
            context: context,
            title: 'rate_app'.tr(),
            onSubmit: (rating, comment) =>
                context.read<ProfileCubit>().rateApp(rating, comment),
          ),
        ),
        _navTile(
          context,
          icon: Icons.receipt_long_outlined,
          title: 'my_orders'.tr(),
          trailing: arrow,
          onTap: () => context.pushNamed(AppRouterKeys.myOrdersScreen),
        ),
        _navTile(
          context,
          icon: Icons.auto_awesome,
          title: 'my_custom_orders'.tr(),
          trailing: arrow,
          onTap: () => requireAuth(
            context,
            () => context.pushNamed(AppRouterKeys.myCustomOrders),
          ),
        ),
        _navTile(
          context,
          icon: Icons.notifications_none,
          title: 'notifications'.tr(),
          trailing: arrow,
          onTap: () => context.pushNamed(AppRouterKeys.notificationScreen),
        ),
      ],
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: onTap,
        child: ProfileTile(icon: icon, title: title, trailing: trailing),
      ),
    );
  }
}
