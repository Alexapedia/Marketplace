import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_logo.dart';
import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/components/product_card.dart';
import '../../../../core/models/catalog_models.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/require_auth.dart';
import '../controller/home_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..load(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Scaffold(
      body: RefreshIndicator(
        color: gold,
        onRefresh: () => context.read<HomeCubit>().load(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              title: const AppLogo(height: 32),
              actions: [
                IconButton(
                  onPressed: () => requireAuth(
                    context,
                    () => context.pushNamed(AppRouterKeys.cart),
                  ),
                  icon: BlocBuilder<AppControllerCubit, AppControllerState>(
                    builder: (context, state) {
                      return badges.Badge(
                        showBadge: state.cartItemsCount > 0,
                        badgeContent: Text(
                          '${state.cartItemsCount}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => requireAuth(
                    context,
                    () => context.pushNamed(AppRouterKeys.notificationScreen),
                  ),
                  icon: BlocBuilder<AppControllerCubit, AppControllerState>(
                    builder: (context, state) {
                      return badges.Badge(
                        showBadge: state.countOfUnReadNot > 0,
                        badgeContent: Text(
                          '${state.countOfUnReadNot}',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        child: const Icon(Icons.notifications_none_rounded),
                      );
                    },
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GestureDetector(
                  onTap: () => context.pushNamed(AppRouterKeys.search),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'search_hint'.tr(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state.status == RequestStatus.failed) {
                    return FailedShape(
                      msg: state.error,
                      onTapRefresh: () => context.read<HomeCubit>().load(),
                    );
                  }
                  final loading = state.status == RequestStatus.loading;
                  return Skeletonizer(
                    enabled: loading,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Banners(banners: state.config.banners),
                        SectionHeader(title: 'shop_by_category'.tr()),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: loading ? 6 : state.categories.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final c = loading
                                  ? const CategoryModel(name: 'Category')
                                  : state.categories[i];
                              return ActionChip(
                                avatar: CircleAvatar(
                                  backgroundColor: gold.withValues(alpha: 0.2),
                                  child: const Icon(Icons.category_outlined, size: 16),
                                ),
                                label: Text(c.name),
                                onPressed: () => context.pushNamed(
                                  AppRouterKeys.products,
                                  extra: {'categoryId': c.id, 'title': c.name},
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: _CustomCta(),
                        ),
                        _ProductRow(
                          title: 'featured'.tr(),
                          products: state.featured,
                          loading: loading,
                          query: {'featured': true},
                        ),
                        _ProductRow(
                          title: 'new_arrivals'.tr(),
                          products: state.newArrivals,
                          loading: loading,
                          query: {'newArrival': true},
                        ),
                        _ProductRow(
                          title: 'best_sellers'.tr(),
                          products: state.bestSellers,
                          loading: loading,
                          query: {'bestSeller': true},
                        ),
                        const SizedBox(height: 88),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banners extends StatefulWidget {
  const _Banners({required this.banners});
  final List banners;
  @override
  State<_Banners> createState() => _BannersState();
}

class _BannersState extends State<_Banners> {
  final controller = PageController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: Theme.of(context).extension<AppColors>()!.brandGradient,
          ),
          child: const Center(
            child: AppLogo(height: 72, onDarkSurface: true),
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            itemBuilder: (context, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ImageItem(b.image, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Text(
                          b.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (banners.length > 1)
          SmoothPageIndicator(
            controller: controller,
            count: banners.length,
            effect: WormEffect(
              dotHeight: 7,
              dotWidth: 7,
              activeDotColor: Theme.of(context).extension<AppColors>()!.gold,
            ),
          ),
      ],
    );
  }
}

class _CustomCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => requireAuth(
        context,
        () => context.pushNamed(AppRouterKeys.customOrder),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: Theme.of(context).extension<AppColors>()!.brandGradient,
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'custom_order_cta_title'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'custom_order_cta_body'.tr(),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.products,
    required this.loading,
    required this.query,
  });
  final String title;
  final List<ProductModel> products;
  final bool loading;
  final Map<String, dynamic> query;

  @override
  Widget build(BuildContext context) {
    final items = loading
        ? List.generate(4, (_) => const ProductModel(name: 'Product', price: 100))
        : products;
    if (!loading && items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SectionHeader(
          title: title,
          onSeeAll: () => context.pushNamed(
            AppRouterKeys.products,
            extra: {'query': query, 'title': title},
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 160,
              child: ProductCard(product: items[i], index: i),
            ),
          ),
        ),
      ],
    );
  }
}
