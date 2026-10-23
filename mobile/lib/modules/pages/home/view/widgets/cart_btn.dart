import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/utils/functions/require_auth.dart';

class CartBtn extends StatelessWidget {
  const CartBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          requireAuth(context, () => context.pushNamed(AppRouterKeys.cart)),
      icon: BlocBuilder<AppControllerCubit, AppControllerState>(
        builder: (context, state) {
          return Semantics(
            label: 'a11y_cart_items'.tr(args: ['${state.cartItemsCount}']),
            excludeSemantics: true,
            child: badges.Badge(
              showBadge: state.cartItemsCount > 0,
              badgeStyle: const badges.BadgeStyle(padding: EdgeInsets.all(5)),
              badgeContent: Text(
                '${state.cartItemsCount}',
                style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white, height: 1),
              ),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          );
        },
      ),
    );
  }
}
