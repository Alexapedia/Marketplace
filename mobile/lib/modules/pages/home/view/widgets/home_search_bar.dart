import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/responsive.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outline = theme.extension<AppColors>()!.inputBorder;
    OutlineInputBorder pill([Color? c]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: c ?? outline),
    );
    final field = GestureDetector(
      onTap: () => context.pushNamed(AppRouterKeys.search),
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            hintText: embedded ? 'search'.tr() : 'search_hint'.tr(),
            hintStyle: TextStyle(fontSize: context.font(embedded ? 13 : 14)),
            prefixIcon: const Icon(Icons.search, size: 22),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: pill(),
            enabledBorder: pill(),
            focusedBorder: pill(),
            disabledBorder: pill(),
            isDense: embedded,
            contentPadding: embedded
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : null,
          ),
        ),
      ),
    );
    if (embedded) return field;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(height: 52, child: field),
    );
  }
}
