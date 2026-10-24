import 'package:dartz/dartz.dart';
import 'package:placemarket_mobile/core/models/api_model.dart';

import 'test_locator.dart';

/// Compact, deterministic API answers for layout tests (no network).
Map<String, dynamic> _product(
  String id,
  String en,
  String ar,
  num price, {
  num? sale,
  int rating = 0,
  String? cat,
}) => {
  '_id': id,
  'names': {'en': en, 'ar': ar},
  'descriptions': {
    'en': 'A rich fragrance with amber and musk, hand finished.',
    'ar': 'عطر غني بالعنبر والمسك، مصنوع يدويًا بعناية.',
  },
  'images': [
    'https://example.invalid/$id-1.jpg',
    'https://example.invalid/$id-2.jpg',
  ],
  'price': price,
  'salePrice': sale,
  'stock': 12,
  'sizes': const [],
  'variants': const [],
  'flags': {'featured': true},
  'status': 'published',
  'ratingAvg': rating,
  'ratingCount': rating,
  'categoryId': {
    '_id': 'c1',
    'names': {'en': 'Perfumes', 'ar': 'عطور'},
  },
};

final _products = [
  _product('p1', 'Oud Royale', 'عود ملكي', 420, sale: 380, rating: 5),
  _product('p2', 'Rose Mist', 'ضباب الورد', 260),
  _product(
    'p3',
    'Classic Chronograph Steel',
    'كرونوغراف كلاسيكي من الفولاذ',
    1450,
  ),
  _product('p4', 'Gold Chain', 'سلسلة ذهبية', 540, sale: 480),
  _product('p5', 'Linen Shirt', 'قميص كتان', 390),
  _product('p6', 'Amber Absolute', 'عنبر مطلق', 480, rating: 4),
];

final _categories = [
  for (final c in const [
    ('c1', 'Perfumes', 'عطور'),
    ('c2', 'Watches', 'ساعات'),
    ('c3', 'Accessories', 'إكسسوارات'),
    ('c4', 'Clothing', 'ملابس'),
  ])
    {
      '_id': c.$1,
      'names': {'en': c.$2, 'ar': c.$3},
      'image': 'https://example.invalid/${c.$1}.jpg',
    },
];

const _tenant = {
  'status': 'active',
  'channels': {'mobile': true},
  'branding': {
    'name': 'Zezo Store',
    'primary': '#071345',
    'accent': '#c9a45c',
    'logo': '',
    'logoDark': '',
  },
};

Map<String, dynamic>? _body(String path) {
  switch (path) {
    case '/home':
      return {
        'data': {
          'config': {'tenant': _tenant, 'settings': const {}},
          'ads': [
            {
              '_id': 'b1',
              'image': 'https://example.invalid/b1.jpg',
              'title': {'en': 'Ramadan Edit', 'ar': 'إصدار رمضان'},
              'subtitle': {'en': 'Seasonal picks', 'ar': 'اختيارات الموسم'},
              'placement': 'home',
            },
            {
              '_id': 'b2',
              'image': 'https://example.invalid/b2.jpg',
              'title': {'en': 'Custom luxury', 'ar': 'فخامة حسب الطلب'},
              'placement': 'both',
            },
          ],
          'categories': _categories,
          'featured': _products,
          'newArrivals': _products.reversed.toList(),
          'bestSellers': _products.take(4).toList(),
          'highlights': [
            {
              '_id': 'r1',
              'rating': 5,
              'comment':
                  'Exquisite scent, lasts all day and arrives beautifully packed.',
              'userName': 'Noura',
            },
          ],
        },
      };
    case '/products':
      return {
        'data': _products,
        'meta': {'page': 1, 'pages': 1, 'total': 6},
      };
    case '/cart':
      return {
        'data': {
          'items': [
            for (var i = 0; i < 3; i++)
              {
                '_id': 'ci$i',
                'productId': _products[i],
                'quantity': i + 1,
                'unitPrice': _products[i]['price'],
              },
          ],
          'subtotal': 3000,
          'total': 3000,
        },
      };
    case '/orders':
      return {
        'data': [
          for (var i = 0; i < 3; i++)
            {
              '_id': '6ac3000000000000000000$i$i',
              'status': const ['pending', 'preparing', 'delivered'][i],
              'items': [
                {
                  '_id': 'x',
                  'productId': _products[i],
                  'quantity': 1,
                  'unitPrice': 100,
                },
              ],
              'total': 115.0 + i,
              'createdAt': '2026-10-2${i}T10:00:00.000Z',
            },
        ],
        'meta': {'page': 1, 'pages': 1, 'total': 3},
      };
    case '/addresses':
      return {
        'data': [
          {
            '_id': 'a1',
            'label': 'Home',
            'fullName': 'Sara Al-Harbi',
            'phone': '+966500000001',
            'city': 'Riyadh',
            'street': 'King Fahd Rd, Al Olaya',
            'isDefault': true,
          },
        ],
      };
    case '/auth/me':
      return {
        'data': {'name': 'Sara Al-Harbi', 'email': 'sara@example.com'},
      };
  }
  if (path.startsWith('/products/')) {
    return {
      'data': {
        ..._products.first,
        'related': _products.skip(1).take(4).toList(),
      },
    };
  }
  if (path.startsWith('/reviews')) {
    return {'data': const []};
  }
  return null;
}

/// FakeApiConsumer that answers GETs from the fixtures above.
class LayoutApi extends FakeApiConsumer {
  @override
  Future<Either<String, ApiModel>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    calls.add((method: 'GET', path: path, body: null, headers: null));
    final body = _body(path) ?? {'data': const []};
    return right(ApiModel(response: body, statusCode: 200));
  }
}
