import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/circle_back_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/gold_stepper.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/status_label.dart';
import '../controller/custom_order_details_cubit.dart';
import 'widgets/custom_order_details_body.dart';

class CustomOrderDetailsScreen extends StatelessWidget {
  const CustomOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  static const _steps = [
    'submitted',
    'under_review',
    'quote_sent',
    'waiting_confirmation',
  ];

  static String _compact(String status) {
    switch (status) {
      case 'need_more_details':
        return 'under_review';
      case 'confirmed':
      case 'in_preparation':
      case 'ready_shipped':
      case 'completed':
        return 'waiting_confirmation';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomOrderDetailsCubit()..load(orderId),
      child: BlocBuilder<CustomOrderDetailsCubit, CustomOrderDetailsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.blackColor,
              foregroundColor: Colors.white,
              leading: const CircleBackButton(),
              title: Text('custom_order'.tr()),
              actions: [
                IconButton(
                  onPressed: () =>
                      context.pushNamed(AppRouterKeys.chat, extra: orderId),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: GoldDotStepper(
                  steps: _steps,
                  current: _compact(state.order?.status ?? 'submitted'),
                  labelOf: statusLabel,
                ),
              ),
            ),
            body: SafeArea(child: _content(context, state)),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, CustomOrderDetailsState state) {
    if (state.status == RequestStatus.loading) return const LoadingItem();
    if (state.order == null) {
      return FailedShape(
        msg: state.error,
        onTapRefresh: () =>
            context.read<CustomOrderDetailsCubit>().load(orderId),
      );
    }
    return CustomOrderDetailsBody(order: state.order!);
  }
}
