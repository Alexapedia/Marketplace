import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/utils/functions/paged_cubit.dart';

typedef OrdersState = PagedState<OrderModel>;

class OrdersCubit extends PagedCubit<OrderModel> {
  @override
  String get path => EndPoints.orders;

  @override
  OrderModel parse(dynamic json) => OrderModel.fromJson(json);
}
