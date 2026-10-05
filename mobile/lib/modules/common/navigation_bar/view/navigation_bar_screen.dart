import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/functions/responsive.dart';
import '../controller/navigation_bar_cubit.dart';
import 'widgets/app_nav_rail.dart';
import 'widgets/bottom_navbar_item.dart';

class NavigationBarScreen extends StatelessWidget {
  const NavigationBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBarCubit, NavigationBarState>(
      builder: (context, state) {
        final controller = context.read<NavigationBarCubit>();
        final rail = context.useNavRail;
        return PopScope(
          canPop: state.selectedPage == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) controller.getPageIndex(0);
          },
          child: Scaffold(
            body: Row(
              children: [
                if (rail)
                  AppNavRail(
                    selectedIndex: state.selectedPage,
                    onTap: controller.getPageIndex,
                    tabs: controller.navItems,
                  ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    left: (context.locale.languageCode == 'ar') && !rail,
                    right: context.locale.languageCode == 'ar' && rail,
                    child: IndexedStack(
                      index: state.selectedPage,
                      children: controller.screens,
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: rail
                ? null
                : BottomNavbarItem(
                    selectedIndex: state.selectedPage,
                    onTap: controller.getPageIndex,
                    tabs: controller.navItems,
                  ),
          ),
        );
      },
    );
  }
}
