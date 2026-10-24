import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/models/catalog_models.dart';

void main() {
  group('ProductModel variants', () {
    final product = ProductModel.fromJson({
      '_id': 'p1',
      'names': {'en': 'Oud', 'ar': 'عود'},
      'price': 400,
      'salePrice': 380,
      'stock': 5,
      'variants': [
        {'name': '50ml', 'price': 250, 'stock': 0},
        {'sku': 'OUD-100', 'stock': 3},
      ],
    });

    test('parses variant keys from name, falling back to SKU', () {
      expect(product.variants.map((v) => v.key), ['50ml', 'OUD-100']);
    });

    test('variant price overrides the product price when set', () {
      expect(product.priceFor('50ml'), 250);
      expect(product.priceFor('OUD-100'), 380); // no own price → sale price
      expect(product.priceFor(null), 380);
    });

    test('variant stock overrides product stock', () {
      expect(product.stockFor('50ml'), 0);
      expect(product.stockFor('OUD-100'), 3);
      expect(product.stockFor('unknown'), 5);
    });
  });
}
