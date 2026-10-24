import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/categories_cubit.dart';
import 'widgets/categories_body.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit()..load(),
      child: Scaffold(
        appBar: AppBar(title: Text('categories'.tr())),
        body: SafeArea(
                    left: context.locale.languageCode == 'ar',
          right: context.locale.languageCode == 'en',
          child: const CategoriesBody()),
      ),
    );
  }
}
