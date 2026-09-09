import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/functions/require_auth.dart';
import '../controller/navigation_bar_cubit.dart';
import 'widgets/bottom_navbar_item.dart';

class NavigationBarScreen extends StatelessWidget {
  const NavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        final controller = context.read<NavigationBarCubit>();
        return Scaffold(
          body: IndexedStack(
            index: state.selectedPage,
            children: controller.screens,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => requireAuth(
              context,
              () => context.pushNamed(AppRouterKeys.customOrder),
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text('custom_order'.tr()),
            backgroundColor: gold,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: BottomNavbarItem(
            selectedIndex: state.selectedPage,
            onTap: controller.getPageIndex,
            tabs: controller.navItems,
          ),
        );
      },
    );
  }
}
