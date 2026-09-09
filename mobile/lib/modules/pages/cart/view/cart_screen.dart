import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('cart'.tr()),
          actions: [
            IconButton(
              onPressed: () => context.read<CartCubit>().clear(),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'clear_cart'.tr(),
            ),
          ],
        ),
        body: BlocBuilder<CartCubit, CartState>(
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
            final gold = Theme.of(context).extension<AppColors>()!.gold;
            return Skeletonizer(
              enabled: loading,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: loading ? 3 : items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        if (loading) {
                          return const ListTile(title: Text('Item'), subtitle: Text('0'));
                        }
                        final item = items[i];
                        final name = item.product?.name ?? 'item'.tr();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ImageItem(
                                  item.product?.cover ?? '',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    if (item.size != null) Text('${'size'.tr()}: ${item.size}'),
                                    Text(
                                      '${item.lineTotal.toStringAsFixed(0)} ${'currency'.tr()}',
                                      style: TextStyle(color: gold, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => context.read<CartCubit>().updateQty(item.id, item.quantity + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: () => context.read<CartCubit>().updateQty(item.id, item.quantity - 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('total'.tr(), style: const TextStyle(fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text(
                              '${state.cart.total.toStringAsFixed(0)} ${'currency'.tr()}',
                              style: TextStyle(color: gold, fontWeight: FontWeight.w800, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          onTap: items.isEmpty
                              ? null
                              : () => context.pushNamed(AppRouterKeys.checkout),
                          title: 'checkout'.tr(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
