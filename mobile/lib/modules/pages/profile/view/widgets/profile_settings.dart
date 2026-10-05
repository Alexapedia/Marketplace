import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import 'profile_tile.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key, required this.state});

  final AppControllerState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'settings'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ProfileTile(
          icon: Icons.language,
          title: 'language'.tr(),
          trailing: SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'en', label: Text('english'.tr(),style:   TextStyle(fontSize: context.font(14)),)),
              ButtonSegment(value: 'ar', label: Text('arabic'.tr(),style:   TextStyle(fontSize: context.font(14)),)),
            ],
            selected: {context.locale.languageCode},
            onSelectionChanged: (s) =>
                context.read<AppControllerCubit>().setLocale(context, s.first),
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
    );
  }
}
