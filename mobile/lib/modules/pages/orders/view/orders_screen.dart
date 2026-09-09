import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/require_auth.dart';
import '../controller/orders_cubit.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: Text('orders'.tr())),
        body: EmptyState(
          title: 'login_required'.tr(),
          subtitle: 'login_required_desc'.tr(),
          icon: Icons.receipt_long_outlined,
          action: AppButton(
            onTap: () => requireAuth(context, () {}),
            title: 'login'.tr(),
            size: const Size(220, 48),
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => OrdersCubit()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text('orders'.tr())),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state.status == RequestStatus.failed) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () => context.read<OrdersCubit>().load(),
              );
            }
            final loading = state.status != RequestStatus.loaded;
            if (!loading && state.items.isEmpty) {
              return EmptyState(
                title: 'empty_orders'.tr(),
                subtitle: 'empty_orders_hint'.tr(),
                icon: Icons.receipt_long_outlined,
              );
            }
            final gold = Theme.of(context).extension<AppColors>()!.gold;
            return Skeletonizer(
              enabled: loading,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: loading ? 4 : state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (loading) return const ListTile(title: Text('Order'));
                  final o = state.items[i];
                  return ListTile(
                    onTap: () => context.pushNamed(
                      AppRouterKeys.orderDetails,
                      extra: o.id,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: Theme.of(context).colorScheme.surface,
                    leading: CircleAvatar(
                      backgroundColor: gold.withValues(alpha: 0.15),
                      child: Icon(Icons.local_mall_outlined, color: gold),
                    ),
                    title: Text('#${o.id.length > 8 ? o.id.substring(0, 8) : o.id}'),
                    subtitle: Text(statusLabel(o.status)),
                    trailing: Text(
                      '${o.total.toStringAsFixed(0)} ${'currency'.tr()}',
                      style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
