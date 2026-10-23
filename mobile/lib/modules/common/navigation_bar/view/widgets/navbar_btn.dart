import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controller/navigation_bar_cubit.dart' show NavItemData;
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/motion.dart';

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
    final muted = theme.extension<AppColors>()!.navMuted;
    final labelStyle = theme.textTheme.labelMedium;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: context.motion(AppDurations.base),
                  curve: AppCurves.standard,
                  width: 38,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? activeBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? activeFg : muted,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                      item.label.tr(),
                      style: labelStyle?.copyWith(
                        color: isSelected
                            ? (dark ? gold : AppColors.blackColor)
                            : muted,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .fadeIn(duration: context.motion(180.ms)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
