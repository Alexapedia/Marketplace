import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.categories,
    required this.loading,
  });

  final List<CategoryModel> categories;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final cats = loading
        ? List.generate(4, (_) => const CategoryModel(name: '—'))
        : categories;
    if (!loading && categories.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _chip(
            image: '',
            context,
            label: 'all'.tr(),
            selected: true,
            gold: gold,
            onTap: () => context.pushNamed(AppRouterKeys.products),
          ),
          const SizedBox(width: 6),
          ...cats.map(
            (c) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: _chip(
                image: c.image,
                context,
                label: c.name.isEmpty ? '—' : c.name,
                selected: false,
                gold: gold,
                onTap: loading
                    ? null
                    : () => context.pushNamed(
                        AppRouterKeys.products,
                        extra: {'categoryId': c.id, 'title': c.name},
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required String image,
    required bool selected,
    required Color gold,

    VoidCallback? onTap,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (dark ? gold : AppColors.blackColor)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            if (image.isNotEmpty) ...[
              ImageItem(
                image,
                width: 22,
                height: 22,
                fit: BoxFit.fill,
                borderRadius: BorderRadius.circular(30),
              ),
              SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: context.font(13),
                fontWeight: FontWeight.w600,
                color: selected
                    ? (dark ? const Color(0xFF12141C) : Colors.white)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
