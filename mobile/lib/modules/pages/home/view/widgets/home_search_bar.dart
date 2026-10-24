import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/maison.dart';

/// Search pill that opens the search screen.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    final pill = Semantics(
      button: true,
      label: 'search'.tr(),
      excludeSemantics: true,
      child: Pressable(
        child: Material(
          color: m.surface,
          shape: StadiumBorder(side: BorderSide(color: m.line)),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => context.pushNamed(AppRouterKeys.search),
            child: SizedBox(
              height: embedded ? 44 : 52,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 18, end: 8),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: m.inkMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        embedded ? 'search'.tr() : 'search_hint'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: m.inkMuted),
                      ),
                    ),
                    if (!embedded)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: m.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: m.accentInk,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (embedded) return pill;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, AppSpacing.xs, 16, 0),
      child: pill,
    );
  }
}
