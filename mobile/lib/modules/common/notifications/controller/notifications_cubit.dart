import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/fetch_page.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/utils/functions/safe_emit.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> with SafeEmitMixin<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: RequestStatus.loading));
    final response = await fetchPage(
      EndPoints.notifications,
      page: 1,
      parse: NotificationModel.fromJson,
    );
    if (isClosed) return;
    response.fold(
      (l) => silent
          ? AppToast(l, isError: true)
          : emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (r) => emit(state.copyWith(
        status: RequestStatus.loaded,
        items: r.items,
        page: 1,
        hasMore: r.hasMore,
      )),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loadingMore || state.status != RequestStatus.loaded) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final response = await fetchPage(
      EndPoints.notifications,
      page: next,
      parse: NotificationModel.fromJson,
    );
    if (isClosed) return;
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loadingMore: false));
      },
      (r) => emit(state.copyWith(
        items: [...state.items, ...r.items],
        page: next,
        hasMore: r.hasMore,
        loadingMore: false,
      )),
    );
  }

  Future<void> markRead(String id) async {
    final response =
        await sl.get<ApiConsumer>().patch(EndPoints.readNotification(id), body: {});
    response.fold(
      (l) => AppToast(l, isError: true),
      (_) {
        emit(state.copyWith(
          items: state.items.map((e) => e.id == id ? e.markedRead() : e).toList(),
        ));
        sl.get<AppControllerCubit>().getCountOfUnReadNot();
      },
    );
  }

  Future<void> markAllRead() async {
    final response =
        await sl.get<ApiConsumer>().patch(EndPoints.readAllNotifications, body: {});
    response.fold(
      (l) => AppToast(l, isError: true),
      (_) {
        emit(state.copyWith(items: state.items.map((e) => e.markedRead()).toList()));
        sl.get<AppControllerCubit>().getCountOfUnReadNot();
      },
    );
  }

  /// Optimistically removes the row; restores it if the request fails.
  Future<void> remove(NotificationModel item) async {
    final before = state.items;
    emit(state.copyWith(items: before.where((e) => e.id != item.id).toList()));
    final response = await sl.get<ApiConsumer>().delete(EndPoints.notification(item.id));
    response.fold(
      (l) {
        AppToast(l, isError: true);
        if (!isClosed) emit(state.copyWith(items: before));
      },
      (_) => sl.get<AppControllerCubit>().getCountOfUnReadNot(),
    );
  }
}
