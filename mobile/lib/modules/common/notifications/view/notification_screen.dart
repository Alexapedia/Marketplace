import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/components/failed_shape.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/notifications_cubit.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text('notifications'.tr())),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
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
            final gold = Theme.of(context).extension<AppColors>()!.gold;
            return Skeletonizer(
              enabled: loading,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: loading ? 6 : state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (loading) {
                    return const ListTile(title: Text('Notification'), subtitle: Text('body'));
                  }
                  final n = state.items[i];
                  return ListTile(
                    onTap: () => context.read<NotificationsCubit>().markRead(n.id),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: n.isRead
                        ? Theme.of(context).colorScheme.surface
                        : gold.withValues(alpha: 0.08),
                    leading: Icon(
                      n.isRead ? Icons.notifications_none : Icons.notifications_active_outlined,
                      color: gold,
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w800)),
                    subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
