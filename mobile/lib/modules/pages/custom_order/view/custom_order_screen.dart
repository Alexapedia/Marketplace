import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/custom_order_cubit.dart';
import 'widgets/custom_order_body.dart';

class CustomOrderScreen extends StatelessWidget {
  const CustomOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomOrderCubit()..loadCategories(),
      child: const CustomOrderBody(),
    );
  }
}
