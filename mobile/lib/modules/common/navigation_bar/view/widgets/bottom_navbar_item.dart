import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../controller/navigation_bar_cubit.dart';
import 'navbar_btn.dart';

/// Glass bottom navigation. A soft accent pill slides between items
/// (`base`, expo-out); under reduced motion it jumps.
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
    final m = context.maison;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return GlassSurface(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: SizedBox(
            height: 58,
            child: LayoutBuilder(
              builder: (context, box) {
                final slot = box.maxWidth / tabs.length;
                final start = slot * selectedIndex;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      key: const ValueKey('nav-indicator'),
                      duration: context.motion(AppDurations.base),
                      curve: AppCurves.easeOut,
                      top: 4,
                      bottom: 4,
                      left: rtl ? null : start + 6,
                      right: rtl ? start + 6 : null,
                      width: slot - 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: m.accentSoft,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: m.accent.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(tabs.length, (index) {
                        return Expanded(
                          child: NavbarBtn(
                            item: tabs[index],
                            isSelected: index == selectedIndex,
                            primary: m.accentInk,
                            onTap: () => onTap(index),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
