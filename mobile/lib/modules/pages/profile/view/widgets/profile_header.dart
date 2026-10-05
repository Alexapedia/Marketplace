import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/color_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.state});

  final AppControllerState state;

  @override
  Widget build(BuildContext context) {
    final guest = state.isGuest;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: guest ? null : () => context.pushNamed(AppRouterKeys.editProfile),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: AppColors.blackColor,
              child: ClipOval(
                child: !guest &&
                        (state.user?.avatar != null &&
                            state.user!.avatar!.isNotEmpty)
                    ? ImageItem(
                        state.user!.avatar!,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                      )
                    : Text(
                        guest
                            ? 'Z'
                            : ((state.user?.name.isNotEmpty == true
                                      ? state.user!.name[0]
                                      : 'Z')
                                  .toUpperCase()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guest
                        ? 'hello_guest'.tr()
                        : (state.user?.name.isNotEmpty == true
                              ? state.user!.name
                              : 'welcome'.tr()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  if (!guest && state.user != null)
                    Text(
                      state.user!.email,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  if (!guest)
                    Text(
                      'edit_profile'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).extension<AppColors>()!.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
