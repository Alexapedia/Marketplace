import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/app_logo.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/navigation_bar_cubit.dart';

/// Tablet / landscape navigation: the deep brand band with the store logo,
/// a gold rule and accent pills for the active destination.
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
    final m = context.maison;
    final compact = context.isCompactHeight;
    final width = context.navRailWidth;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bandIsDark = m.onBand != Maison.inkLight;
    final narrow = width < 120;
    return Container(
      width:
          width +
          (isRtl
              ? MediaQuery.paddingOf(context).right
              : MediaQuery.paddingOf(context).left),
      decoration: BoxDecoration(
        color: m.band,
        border: BorderDirectional(
          end: BorderSide(color: m.isDark ? m.line : m.band),
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: true,
        left: !isRtl,
        right: isRtl,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: compact ? 12 : 28),
              Padding(
                padding: EdgeInsetsDirectional.only(start: narrow ? 0 : 6),
                child: Align(
                  alignment: narrow
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: AppLogo(
                    height: compact ? 28 : 40,
                    onDarkSurface: bandIsDark,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: narrow ? 0 : 6),
                  child: const GoldRule(width: 56),
                ),
              ],
              SizedBox(height: compact ? 12 : 28),
              for (var i = 0; i < tabs.length; i++) ...[
                _RailBtn(
                  item: tabs[i],
                  selected: i == selectedIndex,
                  compact: compact,
                  narrow: narrow,
                  onTap: () => onTap(i),
                ),
                SizedBox(height: compact ? 6 : 8),
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
    required this.narrow,
    required this.onTap,
  });

  final NavItemData item;
  final bool selected;
  final bool compact;
  final bool narrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final fg = selected ? m.onAccent : m.onBand.withValues(alpha: 0.82);
    final icon = Icon(
      selected ? item.activeIcon : item.icon,
      size: 22,
      color: fg,
    );
    return Semantics(
      selected: selected,
      button: true,
      label: narrow ? item.label.tr() : null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!selected) HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: AnimatedContainer(
            duration: context.motion(AppDurations.base),
            curve: AppCurves.easeOut,
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 0 : 16,
              vertical: compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: selected ? m.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: narrow
                ? Center(child: icon)
                : Row(
                    children: [
                      icon,
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: fg,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
