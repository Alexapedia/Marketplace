import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/responsive.dart';
import 'profile_tile.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key, required this.state});

  final AppControllerState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MaisonSectionHeader(
          title: 'settings'.tr(),
          eyebrow: 'preferences'.tr(),
          padding: const EdgeInsetsDirectional.only(top: 28, bottom: 14),
        ),
        ProfileGroup(
          children: [
            ProfileTile(
              icon: Icons.language_rounded,
              title: 'language'.tr(),
              trailing: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'en',
                    label: Text(
                      'english'.tr(),
                      style: TextStyle(fontSize: context.font(14)),
                    ),
                  ),
                  ButtonSegment(
                    value: 'ar',
                    label: Text(
                      'arabic'.tr(),
                      style: TextStyle(fontSize: context.font(14)),
                    ),
                  ),
                ],
                selected: {context.locale.languageCode},
                onSelectionChanged: (s) => context
                    .read<AppControllerCubit>()
                    .setLocale(context, s.first),
              ),
            ),
            ProfileTile(
              icon: Icons.brightness_6_outlined,
              title: 'dark_mode'.tr(),
              trailing: Switch(
                value: state.themeMode == ThemeMode.dark,
                onChanged: (v) => context.read<AppControllerCubit>().setTheme(
                  v ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
