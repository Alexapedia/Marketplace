import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/image_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';

/// Category rail: round image medallions with a hairline ring and a label.
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
    final cats = loading
        ? List.generate(5, (_) => const CategoryModel(name: '———'))
        : categories;
    if (!loading && categories.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MaisonSectionHeader(
          title: 'shop_by_category'.tr(),
          eyebrow: 'eyebrow_collections'.tr(),
          onSeeAll: () => context.pushNamed(AppRouterKeys.products),
        ),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cats.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Reveal(
                  child: _Medallion(
                    label: 'all'.tr(),
                    image: '',
                    onTap: () => context.pushNamed(AppRouterKeys.products),
                  ),
                );
              }
              final c = cats[i - 1];
              return Reveal(
                index: i,
                child: _Medallion(
                  label: c.name.isEmpty ? '—' : c.name,
                  image: c.image,
                  onTap: loading
                      ? null
                      : () => context.pushNamed(
                          AppRouterKeys.products,
                          extra: {'categoryId': c.id, 'title': c.name},
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion({required this.label, required this.image, this.onTap});

  final String label;
  final String image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        enabled: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 76,
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: m.accent.withValues(alpha: 0.55)),
                  ),
                  child: ClipOval(
                    child: image.isEmpty
                        ? ColoredBox(
                            color: m.band,
                            child: Icon(
                              Icons.auto_awesome_mosaic_outlined,
                              color: m.onBand,
                              size: 26,
                            ),
                          )
                        : ImageItem(image, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: m.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
