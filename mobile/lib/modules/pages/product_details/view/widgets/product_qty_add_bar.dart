import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/catalog_models.dart';
import '../../../../../core/utils/constant/app_string.dart';
import '../../controller/product_details_cubit.dart';

/// Sticky glass purchase bar: quantity stepper + accent "add to cart" with
/// the running line total.
class ProductQtyAddBar extends StatelessWidget {
  const ProductQtyAddBar({
    super.key,
    required this.product,
    required this.state,
  });

  final ProductModel product;
  final ProductDetailsState state;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final inStock = product.stockFor(state.selectedVariant) > 0;
    final total = product.priceFor(state.selectedVariant) * state.quantity;
    final title = inStock ? 'add_to_cart'.tr() : 'out_of_stock'.tr();
    return GlassSurface(
      elevated: true,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: m.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: m.line),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'a11y_decrease_qty'.tr(),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.read<ProductDetailsCubit>().setQty(
                          state.quantity - 1,
                        );
                      },
                      icon: const Icon(Icons.remove_rounded, size: 18),
                    ),
                    SizedBox(
                      width: 22,
                      child: AnimatedNumber(
                        value: state.quantity.toDouble(),
                        format: (v) => v.round().toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'a11y_increase_qty'.tr(),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.read<ProductDetailsCubit>().setQty(
                          state.quantity + 1,
                        );
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  onTap: inStock
                      ? () {
                          AppControllerCubit.get(context).addToCart(
                            context,
                            productId: product.id,
                            variant: state.selectedVariant,
                            size: state.selectedSize,
                            quantity: state.quantity,
                          );
                        }
                      : null,
                  title: title,
                  child: inStock
                      ? LayoutBuilder(
                          builder: (context, box) {
                            // The running total joins the label only when
                            // both fit without truncating the label.
                            final withTotal = box.maxWidth >= 230;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 18,
                                  color: m.onAccentFill,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: m.onAccentFill,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (withTotal) ...[
                                  Container(
                                    width: 1,
                                    height: 16,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    color: m.onAccentFill.withValues(alpha: 0.35),
                                  ),
                                  AnimatedNumber(
                                    value: total,
                                    format: (v) =>
                                        '${v.toStringAsFixed(0)} ${AppString.currency}',
                                    style: TextStyle(
                                      color: m.onAccentFill,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
