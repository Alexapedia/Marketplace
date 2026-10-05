import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/circle_back_button.dart';
import '../controller/notifications_cubit.dart';
import 'widgets/notifications_body.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text('notifications'.tr()),
        ),
        body: SafeArea(child: const NotificationsBody()),
      ),
    );
  }
}
