import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/functions/paged_cubit.dart';

typedef CustomOrdersListState = PagedState<CustomOrderModel>;

class CustomOrdersListCubit extends PagedCubit<CustomOrderModel> {
  @override
  String get path => EndPoints.customOrders;

  @override
  CustomOrderModel parse(dynamic json) => CustomOrderModel.fromJson(json);
}
