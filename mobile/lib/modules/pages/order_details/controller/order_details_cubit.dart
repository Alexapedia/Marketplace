import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit() : super(const OrderDetailsState());

  Future<void> load(String id) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.order(id));
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            current: OrderModel.fromJson(s.response),
          ),
        );
      },
    );
  }

  Future<void> cancel(String id) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.cancelOrder(id),
      body: {},
    );
    response.fold((l) => AppToast(l, isError: true), (_) {
      AppToast('status_cancelled');
      load(id);
    });
  }

  Future<void> rate(String id, double rating, String comment) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.reviews,
      body: {
        'targetType': 'order',
        'targetId': id,
        'rating': rating,
        'comment': comment,
      },
    );
    response.fold((l) => AppToast(l, isError: true), (_) {
      AppToast('rating_thanks');
      load(id);
    });
  }

  Future<void> rateProduct(String productId, double rating, String comment) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.reviews,
      body: {
        'targetType': 'product',
        'targetId': productId,
        'rating': rating,
        'comment': comment,
      },
    );
    response.fold((l) => AppToast(l, isError: true), (_) {
      AppToast('rating_thanks');
    });
  }
}
