import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/category_icon.dart';

/// Editorial category tile: full-bleed image, soft scrim, display name and
/// an accent "shop" eyebrow.
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final hasImage = category.image.isNotEmpty;
    final fg = hasImage ? Colors.white : m.onBand;
    return Semantics(
      button: true,
      label: category.name,
      excludeSemantics: true,
      child: Pressable(
        child: Material(
          color: hasImage ? m.surface2 : m.band,
          borderRadius: BorderRadius.circular(AppRadius.xl - 4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.pushNamed(
              AppRouterKeys.products,
              extra: {'categoryId': category.id, 'title': category.name},
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  ImageItem(category.image, fit: BoxFit.cover)
                else
                  Align(
                    alignment: const Alignment(0, -0.3),
                    child: Icon(
                      categoryIcon(category.name),
                      color: m.accent,
                      size: 36,
                    ),
                  ),
                if (hasImage)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0, 0.6],
                        colors: [Color(0xA6000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category.name.isEmpty ? '—' : category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: displayStyle(size: 20, color: fg, height: 1.15),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Eyebrow('shop'.tr(), color: m.accent),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: m.accent,
                          ),
                        ],
                      ),
                    ],
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
