import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/navigation_bar_cubit.dart' show NavItemData;
import '../../../../../core/models/color_model.dart';

class NavbarBtn extends StatelessWidget {
  const NavbarBtn({
    super.key,
    required this.item,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  final NavItemData item;
  final bool isSelected;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.extension<AppColors>()!.gold;
    final dark = theme.brightness == Brightness.dark;
    final activeBg = dark ? gold : AppColors.blackColor;
    final activeFg = dark ? const Color(0xFF12141C) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 38,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? activeBg : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? activeFg
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              size: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label.tr(),
            style: TextStyle(
              color: isSelected
                  ? (dark ? gold : AppColors.blackColor)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ).animate(target: isSelected ? 1 : 0).fadeIn(duration: 180.ms),
        ],
      ),
    );
  }
}
