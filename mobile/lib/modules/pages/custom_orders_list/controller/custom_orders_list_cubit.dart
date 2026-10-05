import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'custom_orders_list_state.dart';

class CustomOrdersListCubit extends Cubit<CustomOrdersListState> {
  CustomOrdersListCubit() : super(const CustomOrdersListState());

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.customOrders);
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(data is List ? data : asMap(data)['items'])
            .map(CustomOrderModel.fromJson)
            .toList();
        emit(state.copyWith(status: RequestStatus.loaded, items: list));
      },
    );
  }
}
