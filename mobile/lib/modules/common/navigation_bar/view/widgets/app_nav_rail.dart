import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/navigation_bar_cubit.dart';

class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.tabs,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> tabs;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final compact = context.isCompactHeight;
    final width = context.navRailWidth;
    final isRtl = context.locale.languageCode == 'ar';
    return Container(
      width:
          width +
          (isRtl
              ? MediaQuery.paddingOf(context).right
              : MediaQuery.paddingOf(context).left),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF1A1D2E), Color(0xFF12141C)]
              : const [Color(0xFF0B1D66), AppColors.blackColor],
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        left: !isRtl,
        right: isRtl,

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
          child: Column(
            children: [
              SizedBox(height: (compact ? 8 : 16).height),
              Row(
                children: [
                  Container(
                    width: compact ? 36 : 42,
                    height: compact ? 36 : 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: gold, width: 1.5),
                    ),
                    child: Text(
                      'Z',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.w700,
                        fontSize: context.font(compact ? 16 : 18),
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'app_name'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: context.font(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: (compact ? 12 : 22).height),
              for (var i = 0; i < tabs.length; i++) ...[
                _RailBtn(
                  item: tabs[i],
                  selected: i == selectedIndex,
                  compact: compact,
                  gold: gold,
                  onTap: () => onTap(i),
                ),
                SizedBox(height: (compact ? 8 : 10).height),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RailBtn extends StatelessWidget {
  const _RailBtn({
    required this.item,
    required this.selected,
    required this.compact,
    required this.gold,
    required this.onTap,
  });

  final NavItemData item;
  final bool selected;
  final bool compact;
  final Color gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: selected ? gold : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                selected ? item.activeIcon : item.icon,
                size: compact ? 20 : 22,
                color: selected
                    ? AppColors.blackColor
                    : const Color(0xFFD7DEF8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.blackColor : Colors.white,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: context.font(compact ? 12 : 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
