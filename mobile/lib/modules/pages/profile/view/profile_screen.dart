import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/profile_cubit.dart';
import 'widgets/profile_body.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('profile'.tr())),
        body: SafeArea(
          left: context.locale.languageCode == 'ar',
          right: context.locale.languageCode == 'en',
          child: const ProfileBody(),
        ),
      ),
    );
  }
}
