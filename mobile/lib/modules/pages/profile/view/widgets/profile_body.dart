import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
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
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileHeader(state: state),
            if (guest) const ProfileGuest(),
            ProfileSettings(state: state),
            if (!guest) ...[
              ProfileMenu(state: state),
              const ProfileAccountActions(),
            ],
            const SizedBox(height: 24),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) {
                final v = snap.data?.version ?? '1.0.0';
                return Center(child: Text('${'version'.tr()} $v'));
              },
            ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
