import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/adaptive_page.dart';
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
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              buildWhen: (a, b) => a.hasUnread != b.hasUnread,
              builder: (context, state) => state.hasUnread
                  ? IconButton(
                      tooltip: 'mark_all_read'.tr(),
                      onPressed: () =>
                          context.read<NotificationsCubit>().markAllRead(),
                      icon: const Icon(Icons.done_all_rounded),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: const SafeArea(
          child: AdaptivePage(maxWidth: 720, child: NotificationsBody()),
        ),
      ),
    );
  }
}
