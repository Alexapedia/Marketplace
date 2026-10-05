import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/cart_cubit.dart';
import 'cart_item_tile.dart';
import 'cart_summary.dart';

class CartBody extends StatelessWidget {
  const CartBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.status == RequestStatus.failed) {
          return FailedShape(
            msg: state.error,
            onTapRefresh: () => context.read<CartCubit>().load(),
          );
        }
        final loading = state.status != RequestStatus.loaded;
        final items = state.cart.items;
        if (!loading && items.isEmpty) {
          return EmptyState(
            title: 'empty_cart'.tr(),
            subtitle: 'empty_cart_hint'.tr(),
            icon: Icons.shopping_bag_outlined,
            action: AppButton(
              onTap: () => context.goNamed(AppRouterKeys.navigatorBarScreen),
              title: 'continue_shopping'.tr(),
              size: const Size(220, 48),
            ),
          );
        }
        final split = context.isTablet || context.isDesktop;
        final list = Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: loading ? 3 : items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (loading) {
                return const ListTile(title: Text('Item'), subtitle: Text('0'));
              }
              return CartItemTile(item: items[i]);
            },
          ),
        );
        final summary = CartSummary(
          total: state.cart.total,
          canCheckout: items.isNotEmpty,
          expand: split,
        );
        return Skeletonizer(
          enabled: loading,
          child: split
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    list,
                    ColoredBox(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: SizedBox(
                        width: (context.responsive.width * 0.38).clamp(280, 420),
                        child: summary,
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    list,
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: summary,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
