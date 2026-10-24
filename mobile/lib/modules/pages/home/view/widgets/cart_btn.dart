import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/require_auth.dart';

/// Bag icon with a count badge that bumps when items are added.
class CartBtn extends StatelessWidget {
  const CartBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppControllerCubit, AppControllerState, int>(
      selector: (s) => s.cartItemsCount,
      builder: (context, count) {
        return Semantics(
          label: 'a11y_cart_items'.tr(args: ['$count']),
          button: true,
          excludeSemantics: true,
          onTap: () =>
              requireAuth(context, () => context.pushNamed(AppRouterKeys.cart)),
          child: BumpBadge(
            count: count,
            child: IconButton(
              onPressed: () => requireAuth(
                context,
                () => context.pushNamed(AppRouterKeys.cart),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        );
      },
    );
  }
}
