import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/image_item.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/pages/cart/controller/cart_cubit.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_item_tile.dart';

Widget _tile(CartItemModel item) => BlocProvider(
  create: (_) => CartCubit(),
  child: MaterialApp(
    theme: light(AppColors.lightDefaults),
    home: screenUtilHandler(
      child: Scaffold(
        body: Center(child: CartItemTile(item: item)),
      ),
    ),
  ),
);

void main() {
  // The cart API returns the picture and name on the line itself
  // (`image`, `nameSnapshot`); `product` is not populated.
  testWidgets('shows the cart line image when the product is not populated', (
    tester,
  ) async {
    await tester.pumpWidget(
      _tile(
        const CartItemModel(
          id: 'c1',
          productId: 'p1',
          nameSnapshot: 'Cedar Night',
          image: 'https://example.com/cedar.png',
        ),
      ),
    );

    final image = tester.widget<ImageItem>(find.byType(ImageItem));
    expect(image.img, 'https://example.com/cedar.png');
    expect(find.text('Cedar Night'), findsOneWidget);
  });
}
