import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:placemarket_mobile/config/theme/dark_mode.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';
import 'package:placemarket_mobile/core/models/color_model.dart';
import 'package:placemarket_mobile/modules/pages/order_details/view/widgets/delivery_code_card.dart';

class _NoAssets extends AssetLoader {
  const _NoAssets();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> _pump(WidgetTester tester, OrderModel order) async {
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      assetLoader: const _NoAssets(),
      fallbackLocale: const Locale('en'),
      child: MaterialApp(
        theme: dark(AppColors.darkDefaults),
        home: Scaffold(body: DeliveryCodeCard(order: order)),
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  test('the order model reads the delivery code', () {
    final order = OrderModel.fromJson({
      'data': {'_id': 'o1', 'deliveryCode': '048213'},
    });
    expect(order.deliveryCode, '048213');
    expect(OrderModel.fromJson({'_id': 'o2'}).deliveryCode, '');
  });

  testWidgets('shows the code while the order is on its way', (tester) async {
    await _pump(
      tester,
      const OrderModel(
        id: 'o1',
        status: 'out_for_delivery',
        deliveryCode: '048213',
      ),
    );
    expect(find.text('048213'), findsOneWidget);
    expect(find.text('delivery_code_hint'), findsOneWidget);
  });

  testWidgets('hides the code once the order is completed or cancelled', (
    tester,
  ) async {
    for (final status in ['completed', 'cancelled', 'rejected', 'delivered']) {
      await _pump(
        tester,
        OrderModel(id: 'o1', status: status, deliveryCode: '048213'),
      );
      expect(find.text('048213'), findsNothing, reason: status);
    }
  });

  testWidgets('shows nothing when the order has no code', (tester) async {
    await _pump(tester, const OrderModel(id: 'o1', status: 'pending'));
    expect(find.text('delivery_code'), findsNothing);
  });
}
