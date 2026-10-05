import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/circle_back_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/order_details_cubit.dart';
import 'widgets/order_details_body.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailsCubit()..load(orderId),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text('order_details'.tr()),
        ),
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            if (state.status == RequestStatus.loading ||
                state.status == RequestStatus.init) {
              return const LoadingItem();
            }
            if (state.current == null) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () =>
                    context.read<OrderDetailsCubit>().load(orderId),
              );
            }
            return OrderDetailsBody(order: state.current!);
          },
        ),
      ),
    );
  }
}
