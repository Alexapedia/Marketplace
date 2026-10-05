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

class SplitHome extends StatelessWidget {
  const SplitHome({super.key, required this.state, required this.loading});

  final HomeState state;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!context.useNavRail) const HomeSearchBar(),
                AdsPart(ads: state.ads),
                CategoryStrip(categories: state.categories, loading: loading),
                const CustomOrderCta(),
                ReviewsStrip(reviews: state.highlights, stacked: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProductRow(
                  title: 'featured'.tr(),
                  products: state.featured,
                  loading: loading,
                  query: const {'featured': true},
                  heroScope: 'featured',
                  columns: 2,
                ),
                ProductRow(
                  title: 'new_arrivals'.tr(),
                  products: state.newArrivals,
                  loading: loading,
                  query: const {'newArrival': true},
                  heroScope: 'new',
                  columns: 2,
                ),
                ProductRow(
                  title: 'best_sellers'.tr(),
                  products: state.bestSellers,
                  loading: loading,
                  query: const {'bestSeller': true},
                  heroScope: 'best',
                  columns: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
