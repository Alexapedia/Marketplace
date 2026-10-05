import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'custom_order_details_state.dart';

class CustomOrderDetailsCubit extends Cubit<CustomOrderDetailsState> {
  CustomOrderDetailsCubit() : super(const CustomOrderDetailsState());

  Future<void> load(String id) async {
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().get(EndPoints.customOrder(id));
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) => emit(
        state.copyWith(
          status: RequestStatus.loaded,
          order: CustomOrderModel.fromJson(s.response),
        ),
      ),
    );
  }

  Future<void> confirm(String orderId, String proposalId, {String? addressId}) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.confirmCustomOrder(orderId),
      body: {
        'proposalId': proposalId,
        if (addressId != null && addressId.isNotEmpty) 'addressId': addressId,
      },
    );
    response.fold((l) => AppToast(l, isError: true), (_) {
      AppToast('order_placed');
      load(orderId);
    });
  }

  Future<void> reject(String orderId, String proposalId, String reason) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.rejectCustomOrder(orderId),
      body: {'proposalId': proposalId, 'reason': reason},
    );
    response.fold((l) => AppToast(l, isError: true), (_) => load(orderId));
  }
}
