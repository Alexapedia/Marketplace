import 'package:flutter/material.dart';

import '../../controller/navigation_bar_cubit.dart';
import 'navbar_btn.dart';

class BottomNavbarItem extends StatelessWidget {
  const BottomNavbarItem({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
  });

  final int selectedIndex;
  final Function(int) onTap;
  final List<NavItemData> tabs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.secondary;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              return NavbarBtn(
                item: tabs[index],
                isSelected: index == selectedIndex,
                primary: primary,
                onTap: () => onTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}
