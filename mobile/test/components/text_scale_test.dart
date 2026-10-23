import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/gold_stepper.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/view/widgets/navbar_btn.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/cart_btn.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/notif_btn.dart';

Widget _wrap(
  Widget child,
  AppControllerCubit cubit, {
  TextDirection dir = TextDirection.ltr,
  double scale = 1,
}) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    theme: light(AppColors.lightDefaults),
    builder: (context, c) => Directionality(
      textDirection: dir,
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: c!,
      ),
    ),
    home: screenUtilHandler(
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

const _nav = NavItemData(
  icon: Icons.home_outlined,
  activeIcon: Icons.home,
  label: 'home',
);

void _walk(InlineSpan span, TextStyle? parent, List<double> out) {
  final style = span.style == null
      ? parent
      : (parent?.merge(span.style) ?? span.style);
  if (span is TextSpan) {
    if ((span.text ?? '').isNotEmpty && style?.fontSize != null) {
      out.add(style!.fontSize!);
    }
    for (final c in span.children ?? const <InlineSpan>[]) {
      _walk(c, style, out);
    }
  }
}

void main() {
  void useSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'no Text under 12sp in ProductCard, NavbarBtn, GoldDotStepper and the cart/notification badges',
    (tester) async {
      useSize(tester);
      final cubit = AppControllerCubit();
      // ignore: invalid_use_of_protected_member
      cubit.emit(cubit.state.copyWith(cartItemsCount: 3, countOfUnReadNot: 4));
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 180,
                  height: 300,
                  child: ProductCard(
                    product: ProductModel(
                      id: 'p1',
                      name: 'Vase',
                      price: 100,
                      salePrice: 80,
                    ),
                  ),
                ),
                NavbarBtn(
                  item: _nav,
                  isSelected: false,
                  primary: Colors.black,
                  onTap: () {},
                ),
                GoldDotStepper(
                  steps: const ['a', 'b', 'c'],
                  current: 'b',
                  labelOf: (s) => s,
                ),
                const Row(children: [CartBtn(), NotifBtn()]),
              ],
            ),
          ),
          cubit,
        ),
      );
      await tester.pumpAndSettle();
      final sizes = <double>[];
      for (final p in tester.renderObjectList<RenderParagraph>(
        find.byType(RichText),
      )) {
        _walk(p.text, null, sizes);
      }
      expect(sizes, isNotEmpty);
      expect(sizes.where((s) => s < 12), isEmpty, reason: '$sizes');
    },
  );

  testWidgets(
    'ProductCard and nav bar render in Arabic at TextScaler 1.6 without overflow',
    (tester) async {
      useSize(tester);
      final cubit = AppControllerCubit();
      await tester.pumpWidget(
        _wrap(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 180,
                height: 300,
                child: ProductCard(
                  product: ProductModel(
                    id: 'p1',
                    name: 'عطر عود فاخر بإصدار محدود',
                    price: 1250,
                    salePrice: 990,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: NavbarBtn(
                  item: _nav,
                  isSelected: true,
                  primary: Colors.black,
                  onTap: () {},
                ),
              ),
            ],
          ),
          cubit,
          dir: TextDirection.rtl,
          scale: 1.6,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
