import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../controller/navigation_bar_cubit.dart' show NavItemData;

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

  /// Active colour (accent-ink).
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final color = isSelected ? primary : m.inkMuted;
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            if (!isSelected) HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected && !context.reduceMotion ? 1.08 : 1,
                    duration: context.motion(AppDurations.base),
                    curve: AppCurves.easeOut,
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: context.motion(AppDurations.fast),
                    style: labelStyle!.copyWith(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    child: Text(
                      item.label.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
