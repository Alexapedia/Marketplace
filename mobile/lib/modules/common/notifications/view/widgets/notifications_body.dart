import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/app_models.dart';
import '../../../../../core/components/infinite_scroll.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/notifications_cubit.dart';
import 'notification_tile.dart';
import '../../../../../core/components/skeleton_placeholders.dart';

class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotificationsCubit>();
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(msg: state.error, onTapRefresh: cubit.load);
        }
        final loading = state.status != RequestStatus.loaded;
        if (!loading && state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => cubit.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: EmptyState(
                    title: 'empty_notifications'.tr(),
                    icon: Icons.notifications_none_rounded,
                  ),
                ),
              ],
            ),
          );
        }
        return MaisonSkeleton(
          enabled: loading,
          child: InfiniteScroll(
            onRefresh: () => cubit.load(silent: true),
            onLoadMore: cubit.loadMore,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: loading
                  ? 6
                  : state.items.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (loading) {
                  return NotificationTile(
                    item: NotificationModel(
                      title: 'Notification title',
                      body: 'Notification body text goes here',
                      isRead: true,
                    ),
                  );
                }
                if (i >= state.items.length) return const LoadMoreFooter();
                final item = state.items[i];
                return Dismissible(
                  key: ValueKey('notif-${item.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: AlignmentDirectional.centerEnd,
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      semanticLabel: 'delete'.tr(),
                    ),
                  ),
                  onDismissed: (_) => cubit.remove(item),
                  child: Reveal(
                    index: i,
                    child: NotificationTile(item: item),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
