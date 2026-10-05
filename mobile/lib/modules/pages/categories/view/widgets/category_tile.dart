import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/category_icon.dart';
import '../../../../../core/utils/functions/responsive.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Material(
      color: colors.surfaceContainerLight.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0 : 1,
      ),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.pushNamed(
          AppRouterKeys.products,
          extra: {'categoryId': category.id, 'title': category.name},
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : colors.surfaceContainerLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (category.image.isNotEmpty)
                Expanded(child: ImageItem(category.image, fit: BoxFit.cover))
              else
                Expanded(
                  child: Center(
                    child: Icon(
                      categoryIcon(category.name),
                      color: colors.gold,
                      size: 28.width,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  category.name.isEmpty ? '—' : category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: context.font(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'shop'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: context.font(12),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ),
              SizedBox(height: 12.height),
            ],
          ),
        ),
      ),
    );
  }
}
