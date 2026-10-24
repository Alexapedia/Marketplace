import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/maison.dart';
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
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: context.maison.inkMuted,
    );
    ProfileTile tile(IconData icon, String title, VoidCallback onTap) =>
        ProfileTile(icon: icon, title: title, trailing: arrow, onTap: onTap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaisonSectionHeader(
          title: 'your_account'.tr(),
          padding: const EdgeInsetsDirectional.only(top: 28, bottom: 14),
        ),
        ProfileGroup(
          children: [
            tile(
              Icons.person_outline_rounded,
              'edit_profile'.tr(),
              () => context.pushNamed(AppRouterKeys.editProfile),
            ),
            tile(
              Icons.receipt_long_outlined,
              'my_orders'.tr(),
              () => context.pushNamed(AppRouterKeys.myOrdersScreen),
            ),
            tile(
              Icons.favorite_border_rounded,
              'favorites'.tr(),
              () => requireAuth(
                context,
                () => context.pushNamed(AppRouterKeys.favorites),
              ),
            ),
            tile(
              Icons.location_on_outlined,
              'my_addresses'.tr(),
              () => requireAuth(
                context,
                () => context.pushNamed(AppRouterKeys.addresses),
              ),
            ),
            tile(
              Icons.auto_awesome_outlined,
              'my_custom_orders'.tr(),
              () => requireAuth(
                context,
                () => context.pushNamed(AppRouterKeys.myCustomOrders),
              ),
            ),
            tile(
              Icons.notifications_none_rounded,
              'notifications'.tr(),
              () => context.pushNamed(AppRouterKeys.notificationScreen),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ProfileGroup(
          children: [
            if (state.supportPhone.isNotEmpty || state.supportEmail.isNotEmpty)
              tile(
                Icons.support_agent_rounded,
                'support'.tr(),
                () => SupportSheet.show(
                  context,
                  phone: state.supportPhone,
                  email: state.supportEmail,
                ),
              ),
            tile(
              Icons.star_outline_rounded,
              'rate_app'.tr(),
              () => showRateSheet(
                context: context,
                title: 'rate_app'.tr(),
                onSubmit: (rating, comment) =>
                    context.read<ProfileCubit>().rateApp(rating, comment),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
