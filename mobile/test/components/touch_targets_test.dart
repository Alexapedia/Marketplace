import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/circle_back_button.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/components/star_rating.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/view/widgets/navbar_btn.dart';
import 'package:placemarket_mobile/modules/pages/cart/controller/cart_cubit.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_item_tile.dart';
import 'package:placemarket_mobile/modules/pages/product_details/controller/product_details_cubit.dart';
import 'package:placemarket_mobile/modules/pages/product_details/view/widgets/product_qty_add_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: light(AppColors.lightDefaults),
      home: screenUtilHandler(
        child: Scaffold(body: Center(child: child)),
      ),
    );

void _expect48(WidgetTester tester, Finder f) {
  expect(f, findsOneWidget);
  final s = tester.getSize(f);
  expect(s.width, greaterThanOrEqualTo(48), reason: 'width $s');
  expect(s.height, greaterThanOrEqualTo(48), reason: 'height $s');
}

void main() {
  const product = ProductModel(id: 'p1', name: 'Vase', price: 100);

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider(
      create: (_) => AppControllerCubit(),
      child: _wrap(const SizedBox(
        width: 180,
        height: 270,
        child: ProductCard(product: product),
      )),
    ));
    await tester.pump();
  }

  testWidgets('product card favorite hit area >= 48', (tester) async {
    await pumpCard(tester);
    _expect48(
        tester,
        find.descendant(
            of: find.byType(ProductCard), matching: find.byType(IconButton)));
  });

  testWidgets('product card add-to-cart hit area >= 48', (tester) async {
    await pumpCard(tester);
    final hit = find.descendant(
        of: find.byType(ProductCard),
        matching: find.byKey(const ValueKey('add-to-cart-hit')));
    _expect48(tester, hit);
  });

  testWidgets('product card shows ink splash on tap', (tester) async {
    await pumpCard(tester);
    final ink = find.ancestor(
        of: find.byType(StarRating), matching: find.byType(InkWell));
    expect(ink, findsOneWidget);
    expect(tester.widget<InkWell>(ink).onTap, isNotNull);
  });

  testWidgets('back button hit area >= 48', (tester) async {
    await tester.pumpWidget(_wrap(CircleBackButton(onPressed: () {})));
    _expect48(tester, find.byType(IconButton));
  });

  testWidgets('nav item hit area >= 48 high', (tester) async {
    await tester.pumpWidget(_wrap(SizedBox(
      width: 80,
      child: NavbarBtn(
        item: const NavItemData(
            icon: Icons.home_outlined, activeIcon: Icons.home, label: 'home'),
        isSelected: false,
        primary: Colors.black,
        onTap: () {},
      ),
    )));
    await tester.pumpAndSettle();
    final ink = find.descendant(
        of: find.byType(NavbarBtn), matching: find.byType(InkWell));
    expect(ink, findsOneWidget);
    final s = tester.getSize(ink);
    expect(s.height, greaterThanOrEqualTo(48));
    expect(s.width, 80);
  });

  testWidgets('cart qty +/- hit area >= 48', (tester) async {
    await tester.pumpWidget(BlocProvider(
      create: (_) => CartCubit(),
      child: _wrap(const CartItemTile(
          item: CartItemModel(id: 'c1', productId: 'p1', product: product))),
    ));
    final buttons = find.descendant(
        of: find.byType(CartItemTile), matching: find.byType(IconButton));
    expect(buttons, findsNWidgets(2));
    for (final b in tester.widgetList(buttons)) {
      _expect48(tester, find.byWidget(b));
    }
  });

  testWidgets('product qty +/- hit area >= 48', (tester) async {
    await tester.pumpWidget(BlocProvider(
      create: (_) => ProductDetailsCubit(),
      child: _wrap(const ProductQtyAddBar(
          product: product, state: ProductDetailsState())),
    ));
    await tester.pumpAndSettle();
    final buttons = find.descendant(
        of: find.byType(ProductQtyAddBar), matching: find.byType(IconButton));
    expect(buttons, findsNWidgets(2));
    for (final b in tester.widgetList(buttons)) {
      _expect48(tester, find.byWidget(b));
    }
  });
}
