import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(const NotificationsState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.notifications);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map(NotificationModel.fromJson)
            .toList();
        emit(state.copyWith(status: RequestStatus.loaded, items: list));
      },
    );
  }

  Future<void> markRead(String id) async {
    await sl.get<ApiConsumer>().patch(EndPoints.readNotification(id), body: {});
    emit(
      state.copyWith(
        items: state.items
            .map((e) => e.id == id
                ? NotificationModel(
                    id: e.id,
                    title: e.title,
                    body: e.body,
                    isRead: true,
                    createdAt: e.createdAt,
                    type: e.type,
                    referenceId: e.referenceId,
                  )
                : e)
            .toList(),
      ),
    );
    sl.get<AppControllerCubit>().getCountOfUnReadNot();
  }
}
