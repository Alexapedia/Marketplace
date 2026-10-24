import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/adaptive_page.dart';
import '../../../../core/components/circle_back_button.dart';
import '../controller/products_cubit.dart';
import 'widgets/products_body.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({
    super.key,
    this.title,
    this.categoryId,
    this.search,
    this.query = const {},
    this.autofocus = false,
  });

  final bool autofocus;

  final String? title;
  final String? categoryId;
  final String? search;
  final Map<String, dynamic> query;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductsCubit(
        categoryId: categoryId,
        featured: query['featured'] == true,
        newArrival: query['newArrival'] == true,
        bestSeller: query['bestSeller'] == true,
        search: search,
      )..load(),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 64,
          leading: Navigator.of(context).canPop()
              ? const Padding(
                  padding: EdgeInsetsDirectional.only(start: 8),
                  child: Center(child: CircleBackButton()),
                )
              : null,
          title: Text(title ?? 'search_products'.tr()),
        ),
        body: SafeArea(
          child: AdaptivePage(child: ProductsBody(autofocus: autofocus)),
        ),
      ),
    );
  }
}
