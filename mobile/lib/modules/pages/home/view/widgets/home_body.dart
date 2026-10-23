import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/app_logo.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/home_cubit.dart';
import 'cart_btn.dart';
import 'notif_btn.dart';
import 'portrait_home.dart';
import 'split_home.dart';
import 'wide_app_bar.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final wideHeader = context.useNavRail;
    return Scaffold(
      appBar: wideHeader ? const WideAppBar() : null,
      body: RefreshIndicator(
        color: gold,
        onRefresh: () => context.read<HomeCubit>().load(),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final failed = state.status == RequestStatus.failed;
            final empty =
                state.status == RequestStatus.loaded &&
                state.categories.isEmpty &&
                state.featured.isEmpty &&
                state.newArrivals.isEmpty &&
                state.bestSellers.isEmpty &&
                state.ads.isEmpty;
            final loading = state.status == RequestStatus.loading;
            final cubit = context.read<HomeCubit>();
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (!wideHeader)
                  const SliverAppBar(
                    floating: true,
                    title: AppLogo(height: 32),
                    actions: [CartBtn(), NotifBtn()],
                  ),
                if (failed)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: FailedShape(
                      msg: state.error,
                      onTapRefresh: () => cubit.load(),
                    ),
                  )
                else if (empty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: 'empty_home_title'.tr(),
                      subtitle: 'empty_home_subtitle'.tr(),
                      icon: Icons.storefront_outlined,
                      action: FilledButton.tonalIcon(
                        onPressed: () => cubit.load(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('try_again'.tr()),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: AdaptivePage(
                      child: Skeletonizer(
                        enabled: loading,
                        child: context.isLandscape
                            ? SplitHome(state: state, loading: loading)
                            : PortraitHome(state: state, loading: loading),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
