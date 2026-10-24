import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';

/// Profile hero on the deep brand band: ringed avatar, display name, email
/// and a gold rule.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.state});

  final AppControllerState state;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final guest = state.isGuest;
    final user = state.user;
    final hasAvatar =
        !guest && user?.avatar != null && user!.avatar!.isNotEmpty;
    final name = guest
        ? 'hello_guest'.tr()
        : (user?.name.isNotEmpty == true ? user!.name : 'welcome'.tr());
    final initial = guest
        ? 'Z'
        : (user?.name.isNotEmpty == true
              ? user!.name.characters.first.toUpperCase()
              : 'Z');
    final onBand = m.onBand;
    return Reveal(
      child: Container(
        decoration: BoxDecoration(
          color: m.band,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.one(m.brightness),
          border: m.isDark ? Border.all(color: m.line) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      m.accent.withValues(alpha: 0),
                      m.accent,
                      m.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: guest
                    ? null
                    : () => context.pushNamed(AppRouterKeys.editProfile),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: m.accent, width: 1.5),
                        ),
                        child: ClipOval(
                          child: hasAvatar
                              ? ImageItem(
                                  user.avatar!,
                                  width: 66,
                                  height: 66,
                                  fit: BoxFit.cover,
                                )
                              : ColoredBox(
                                  color: onBand.withValues(alpha: 0.12),
                                  child: Center(
                                    child: Text(
                                      initial,
                                      style: displayStyle(
                                        size: 28,
                                        color: onBand,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: displayStyle(size: 24, color: onBand),
                            ),
                            if (!guest && user != null && user.email.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  user.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: onBand.withValues(alpha: 0.78),
                                      ),
                                ),
                              ),
                            if (!guest)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'edit_profile'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: m.accent),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: m.accent,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
