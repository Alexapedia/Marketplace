import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/home_cubit.dart';
import 'ads_part.dart';
import 'category_strip.dart';
import 'custom_order_cta.dart';
import 'home_search_bar.dart';
import 'product_row.dart';
import 'reviews_strip.dart';

class PortraitHome extends StatelessWidget {
  const PortraitHome({super.key, required this.state, required this.loading});

  final HomeState state;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!context.useNavRail) const HomeSearchBar(),
        AdsPart(ads: state.ads),
        CategoryStrip(categories: state.categories, loading: loading),
        const CustomOrderCta(),
        ProductRow(
          title: 'featured'.tr(),
          products: state.featured,
          loading: loading,
          query: const {'featured': true},
          heroScope: 'featured',
        ),
        ProductRow(
          title: 'new_arrivals'.tr(),
          products: state.newArrivals,
          loading: loading,
          query: const {'newArrival': true},
          heroScope: 'new',
        ),
        ProductRow(
          title: 'best_sellers'.tr(),
          products: state.bestSellers,
          loading: loading,
          query: const {'bestSeller': true},
          heroScope: 'best',
        ),
        ReviewsStrip(reviews: state.highlights),
        SizedBox(height: context.useNavRail ? 24 : 88),
      ],
    );
  }
}
