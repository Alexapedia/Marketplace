import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/functions/app_toast.dart';
import 'product_circle_action.dart';

class ProductShareButton extends StatelessWidget {
  const ProductShareButton({
    super.key,
    required this.product,
    this.filled = false,
  });

  final ProductModel product;
  final bool filled;

  void _share() {
    Clipboard.setData(
      ClipboardData(text: '${'share_product'.tr()} ${product.name}'),
    );
    AppToast('share');
  }

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ProductCircleAction(
        icon: Icons.ios_share_rounded,
        onTap: _share,
      );
    }
    return IconButton.filledTonal(
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withValues(alpha: 0.92)
            : Colors.black.withValues(alpha: 0.92),
      ),
      onPressed: _share,
      icon: const Icon(Icons.ios_share_rounded, size: 18),
    );
  }
}
