import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/infinite_scroll.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../controller/orders_cubit.dart';
import 'order_tile.dart';

class OrdersBody extends StatelessWidget {
  const OrdersBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    if (isGuest) {
      return EmptyState(
        title: 'login_required'.tr(),
        subtitle: 'login_required_desc'.tr(),
        icon: Icons.receipt_long_outlined,
        action: AppButton(
          onTap: () => requireAuth(context, () {}),
          title: 'login'.tr(),
          size: const Size(220, 48),
        ),
      );
    }
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(
            msg: state.error,
            onTapRefresh: () => context.read<OrdersCubit>().load(),
          );
        }
        final loading = state.status != RequestStatus.loaded;
        final cubit = context.read<OrdersCubit>();
        if (!loading && state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: EmptyState(
                    title: 'empty_orders'.tr(),
                    subtitle: 'empty_orders_hint'.tr(),
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
          );
        }
        return Skeletonizer(
          enabled: loading,
          child: InfiniteScroll(
            onRefresh: cubit.refresh,
            onLoadMore: cubit.loadMore,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: loading ? 4 : state.items.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (loading) return ListTile(title: Text('order'.tr()));
                if (i >= state.items.length) return const LoadMoreFooter();
                return OrderTile(order: state.items[i]);
              },
            ),
          ),
        );
      },
    );
  }
}
