import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/adaptive_page.dart';
import 'profile_account_actions.dart';
import 'profile_guest.dart';
import 'profile_header.dart';
import 'profile_menu.dart';
import 'profile_settings.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppControllerCubit, AppControllerState>(
      builder: (context, state) {
        final guest = state.isGuest;
        return AdaptivePage(
          maxWidth: 720,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              ProfileHeader(state: state),
              if (guest) const ProfileGuest(),
              ProfileSettings(state: state),
              if (!guest) ...[
                ProfileMenu(state: state),
                const ProfileAccountActions(),
              ],
              const SizedBox(height: 28),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snap) {
                  final v = snap.data?.version ?? '1.0.0';
                  return Center(
                    child: Text(
                      '${'version'.tr()} $v',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.maison.inkMuted,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 96),
            ],
          ),
        );
      },
    );
  }
}
