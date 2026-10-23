import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/app_text_field.dart';
import 'package:placemarket_mobile/core/components/image_item.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/pages/cart/controller/cart_cubit.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_item_tile.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/cart_btn.dart';
import 'package:placemarket_mobile/modules/pages/product_details/controller/product_details_cubit.dart';
import 'package:placemarket_mobile/modules/pages/product_details/view/widgets/product_qty_add_bar.dart';

Widget _wrap(Widget child) => BlocProvider(
  create: (_) => AppControllerCubit(),
  child: MaterialApp(
    theme: light(AppColors.lightDefaults),
    home: screenUtilHandler(
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  const product = ProductModel(id: 'p1', name: 'Vase', price: 100);

  testWidgets('AppTextField exposes its title as the field label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        AppTextField(
          title: 'Email Address',
          controller: TextEditingController(),
        ),
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Email Address'));
    // ignore: deprecated_member_use
    expect(node.hasFlag(SemanticsFlag.isTextField), isTrue);
    handle.dispose();
  });

  testWidgets('favorite announces add/remove and selected state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 180,
          height: 270,
          child: ProductCard(product: product),
        ),
      ),
    );
    await tester.pump();
    expect(find.bySemanticsLabel('a11y_add_favorite'), findsOneWidget);
    expect(find.bySemanticsLabel('a11y_remove_favorite'), findsNothing);

    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 180,
          height: 270,
          child: ProductCard(
            product: ProductModel(
              id: 'p1',
              name: 'Vase',
              price: 100,
              isFavorite: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final n = tester.getSemantics(
      find.bySemanticsLabel('a11y_remove_favorite'),
    );
    // ignore: deprecated_member_use
    expect(n.hasFlag(SemanticsFlag.isSelected), isTrue);
    handle.dispose();
  });

  testWidgets('add-to-cart is labeled with the product name', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 180,
          height: 270,
          child: ProductCard(product: product),
        ),
      ),
    );
    await tester.pump();
    final n = tester.getSemantics(
      find.byKey(const ValueKey('add-to-cart-hit')),
    );
    expect(n.label, 'a11y_add_to_cart'.tr(args: ['Vase']));
    handle.dispose();
  });

  testWidgets('cart button announces item count', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_wrap(const CartBtn()));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('a11y_cart_items')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('qty buttons are labeled increase/decrease', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => CartCubit(),
        child: _wrap(
          const CartItemTile(
            item: CartItemModel(id: 'c1', productId: 'p1', product: product),
          ),
        ),
      ),
    );
    expect(find.byTooltip('a11y_increase_qty'), findsOneWidget);
    expect(find.byTooltip('a11y_decrease_qty'), findsOneWidget);
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ProductDetailsCubit(),
        child: _wrap(
          const ProductQtyAddBar(
            product: product,
            state: ProductDetailsState(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('a11y_increase_qty'), findsOneWidget);
    expect(find.byTooltip('a11y_decrease_qty'), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
    'product image is labeled with the product name, decorative images are excluded',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              ImageItem('', semanticLabel: 'Vase photo', width: 50, height: 50),
              ImageItem('', width: 50, height: 50),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Vase photo'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ImageItem).last,
          matching: find.byType(Semantics),
        ),
        findsWidgets,
      );
      expect(find.bySemanticsLabel(RegExp('.')).evaluate().length, 1);
      handle.dispose();
    },
  );
}
