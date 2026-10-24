import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/infinite_scroll.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/require_auth.dart';
import '../../controller/orders_cubit.dart';
import 'order_tile.dart';
import '../../../../../core/components/skeleton_placeholders.dart';

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
          size: const Size(240, 52),
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
        return MaisonSkeleton(
          enabled: loading,
          child: InfiniteScroll(
            onRefresh: cubit.refresh,
            onLoadMore: cubit.loadMore,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                // Clears the floating glass bottom navigation.
                24 + MediaQuery.paddingOf(context).bottom,
              ),
              itemCount: loading
                  ? 4
                  : state.items.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (loading) {
                  return OrderTile(
                    order: OrderModel(
                      id: '00000000',
                      status: 'pending',
                      total: 100,
                      createdAt: DateTime(2026, 1, 1),
                    ),
                  );
                }
                if (i >= state.items.length) return const LoadMoreFooter();
                return Reveal(
                  index: i,
                  child: OrderTile(order: state.items[i]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
