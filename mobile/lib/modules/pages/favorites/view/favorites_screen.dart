import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/components/circle_back_button.dart';
import '../controller/favorites_cubit.dart';
import 'widgets/favorites_body.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuest = context.watch<AppControllerCubit>().state.isGuest;
    return BlocProvider(
      create: (_) => isGuest ? FavoritesCubit() : (FavoritesCubit()..load()),
      child: Scaffold(
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text('favorites'.tr()),
        ),
        body: const SafeArea(child: FavoritesBody()),
      ),
    );
  }
}
