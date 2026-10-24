import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/functions/product_hero.dart';
import '../controller/product_details_cubit.dart';
import 'widgets/product_details_body.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});
  final String productId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  // Claimed once so the reverse flight on pop finds the same tag.
  late final hero = ProductHero.claim(widget.productId);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductDetailsCubit()..load(widget.productId),
      child: ProductDetailsBody(heroTag: hero.tag, heroImage: hero.image),
    );
  }
}
