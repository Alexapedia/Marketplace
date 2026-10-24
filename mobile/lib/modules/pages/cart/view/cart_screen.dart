import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/circle_back_button.dart';
import '../controller/cart_cubit.dart';
import 'widgets/cart_body.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartCubit()..load(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 64,
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: Center(child: CircleBackButton()),
          ),
          title: Text('cart'.tr()),
          actions: [
            IconButton(
              onPressed: () => context.read<CartCubit>().clear(),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'clear_cart'.tr(),
            ),
          ],
        ),
        body: const CartBody(),
      ),
    );
  }
}
