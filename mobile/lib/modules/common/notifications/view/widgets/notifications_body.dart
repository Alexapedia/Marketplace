import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/notifications_cubit.dart';
import 'notification_tile.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(
            msg: state.error,
            onTapRefresh: () => context.read<NotificationsCubit>().load(),
          );
        }
        final loading = state.status != RequestStatus.loaded;
        if (!loading && state.items.isEmpty) {
          return EmptyState(
            title: 'empty_notifications'.tr(),
            icon: Icons.notifications_none_rounded,
          );
        }
        return Skeletonizer(
          enabled: loading,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loading ? 6 : state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (loading) {
                return const ListTile(
                  title: Text('Notification'),
                  subtitle: Text('body'),
                );
              }
              return NotificationTile(item: state.items[i]);
            },
          ),
        );
      },
    );
  }
}
