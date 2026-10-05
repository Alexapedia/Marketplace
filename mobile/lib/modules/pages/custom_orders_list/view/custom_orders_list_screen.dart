import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/circle_back_button.dart';
import '../controller/custom_orders_list_cubit.dart';
import 'widgets/custom_orders_list_body.dart';

class CustomOrdersListScreen extends StatelessWidget {
  const CustomOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    return BlocProvider(
      create: (_) => isGuest
          ? CustomOrdersListCubit()
          : (CustomOrdersListCubit()..load()),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text('my_custom_orders'.tr()),
        ),
        floatingActionButton: isGuest
            ? null
            : FloatingActionButton.extended(
                onPressed: () =>
                    context.pushNamed(AppRouterKeys.customOrder),
                icon: const Icon(Icons.add),
                label: Text('start_custom_order'.tr()),
              ),
        body: SafeArea(child: const CustomOrdersListBody()),
      ),
    );
  }
}
