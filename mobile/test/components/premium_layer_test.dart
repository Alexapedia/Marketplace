import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/app_controller/app_controller_cubit.dart';
import 'package:placemarket_mobile/config/theme/light_mode.dart';
import 'package:placemarket_mobile/core/components/product_card.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/core/utils/functions/contrast.dart';
import 'package:placemarket_mobile/core/utils/functions/responsive.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/controller/navigation_bar_cubit.dart';
import 'package:placemarket_mobile/modules/common/navigation_bar/view/widgets/bottom_navbar_item.dart';
import 'package:placemarket_mobile/modules/pages/cart/view/widgets/cart_summary.dart';
import 'package:placemarket_mobile/modules/pages/home/view/widgets/product_row.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Widget _app(Widget home, {bool reduce = false, AppControllerCubit? cubit}) =>
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _NoAssets(),
      fallbackLocale: const Locale('en'),
      child: Builder(
        builder: (context) => BlocProvider.value(
          value: cubit ?? AppControllerCubit(),
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: light(AppColors.lightDefaults),
            builder: (context, c) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
              child: c!,
            ),
            home: screenUtilHandler(child: home),
          ),
        ),
      ),
    );

const _tabs = [
  NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'home'),
  NavItemData(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    label: 'categories',
  ),
];

const _sale = ProductModel(id: 'p1', name: 'Vase', price: 100, salePrice: 80);

Future<void> _load(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  void useSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('bottom nav uses a backdrop blur', (tester) async {
    useSize(tester);
    await tester.pumpWidget(
      _app(
        Scaffold(
          bottomNavigationBar: BottomNavbarItem(
            selectedIndex: 0,
            onTap: (_) {},
            tabs: _tabs,
          ),
        ),
      ),
    );
    await _load(tester);
    expect(
      find.descendant(
        of: find.byType(BottomNavbarItem),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'bottom nav content is not obscured: the last list item is fully visible when scrolled to the end',
    (tester) async {
      useSize(tester);
      await tester.pumpWidget(
        _app(
          Scaffold(
            extendBody: true,
            body: ListView.builder(
              itemCount: 30,
              itemBuilder: (_, i) => ColoredBox(
                key: ValueKey('item-$i'),
                color: Colors.transparent,
                child: SizedBox(height: 56, child: Text('item $i')),
              ),
            ),
            bottomNavigationBar: BottomNavbarItem(
              selectedIndex: 0,
              onTap: (_) {},
              tabs: _tabs,
            ),
          ),
        ),
      );
      await _load(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pumpAndSettle();
      final last = tester.getRect(find.byKey(const ValueKey('item-29')));
      final navTop = tester.getTopLeft(find.byType(BottomNavbarItem)).dy;
      expect(last.bottom, lessThanOrEqualTo(navTop));
    },
  );

  testWidgets('product card sale badge meets 4.5:1 contrast', (tester) async {
    useSize(tester);
    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 240,
              child: ProductCard(product: _sale),
            ),
          ),
        ),
      ),
    );
    await _load(tester);
    final label = find.text('sale');
    expect(label, findsOneWidget);
    final fg = tester.widget<Text>(label).style!.color!;
    final badge = tester.widget<Container>(
      find.ancestor(of: label, matching: find.byType(Container)).first,
    );
    final bg = (badge.decoration! as BoxDecoration).color!;
    expect(contrastRatio(fg, bg), greaterThanOrEqualTo(4.5));
  });

  testWidgets('product card corner radius is 16', (tester) async {
    useSize(tester);
    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: Center(
            child: SizedBox(
              width: 180,
              height: 240,
              child: ProductCard(product: _sale),
            ),
          ),
        ),
      ),
    );
    await _load(tester);
    final box = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(ProductCard),
            matching: find.byType(Container),
          ),
        )
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.boxShadow != null);
    expect(box.borderRadius, BorderRadius.circular(16));
  });

  testWidgets('stagger entrance is disabled under reduce motion', (
    tester,
  ) async {
    useSize(tester);
    Future<void> pump(bool reduce) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: SingleChildScrollView(
              child: ProductRow(
                title: 'T',
                products: [_sale, _sale],
                loading: false,
                query: {},
                heroScope: 'x',
              ),
            ),
          ),
          reduce: reduce,
        ),
      );
      await _load(tester);
    }

    await pump(true);
    expect(find.byType(Animate), findsNothing);
    await pump(false);
    expect(find.byType(Animate), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('cart summary sits inside a SafeArea', (tester) async {
    useSize(tester);
    await tester.pumpWidget(
      _app(const Scaffold(body: CartSummary(total: 10, canCheckout: true))),
    );
    await _load(tester);
    expect(
      find.descendant(
        of: find.byType(CartSummary),
        matching: find.byType(SafeArea),
      ),
      findsOneWidget,
    );
  });
}
