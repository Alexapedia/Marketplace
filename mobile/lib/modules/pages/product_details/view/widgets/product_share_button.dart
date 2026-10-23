import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_string.dart';
import 'product_circle_action.dart';

class ProductShareButton extends StatelessWidget {
  const ProductShareButton({
    super.key,
    required this.product,
    this.filled = false,
  });

  final ProductModel product;
  final bool filled;

  void _share(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      '${'share_product'.tr()} ${product.name} — '
      '${product.displayPrice.toStringAsFixed(0)} ${AppString.currency}',
      subject: product.name,
      // Anchors the share popover on iPad.
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ProductCircleAction(
        icon: Icons.ios_share_rounded,
        tooltip: 'a11y_share'.tr(),
        onTap: () => _share(context),
      );
    }
    return IconButton.filledTonal(
      tooltip: 'a11y_share'.tr(),
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.92)
            : Colors.black.withValues(alpha: 0.92),
      ),
      onPressed: () => _share(context),
      icon: const Icon(Icons.ios_share_rounded, size: 18),
    );
  }
}
