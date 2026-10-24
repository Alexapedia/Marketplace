import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../controller/orders_cubit.dart';
import 'widgets/orders_body.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    return BlocProvider(
      create: (_) => isGuest ? OrdersCubit() : (OrdersCubit()..load()),
      child: Scaffold(
        appBar: AppBar(title: Text('orders'.tr())),
        body: SafeArea(
          left: context.locale.languageCode == 'ar',
          right: context.locale.languageCode == 'en',
          child: const OrdersBody(),
        ),
      ),
    );
  }
}
