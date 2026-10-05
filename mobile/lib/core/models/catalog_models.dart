import '../utils/functions/json_helpers.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String type;
  final String? parentId;
  final List<CategoryModel> children;

  const CategoryModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.image = '',
    this.type = 'standard',
    this.parentId,
    this.children = const [],
  });

  bool get allowsCustom => type == 'custom' || type == 'both';

  factory CategoryModel.fromJson(dynamic json) {
    final map = asMap(json);
    return CategoryModel(
      id: asString(map['_id'] ?? map['id']),
      name: localized(map['name'] ?? map['names']),
      description: localized(map['description'] ?? map['descriptions']),
      image: asString(map['image'] ?? map['imageUrl'] ?? map['icon']),
      type: asString(map['type'], 'standard'),
      parentId: (map['parentId'] ?? map['parent'])?.toString(),
      children: asList(map['children']).map(CategoryModel.fromJson).toList(),
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final String value;
  final double? price;
  final int stock;

  const ProductVariant({
    this.id = '',
    this.name = '',
    this.value = '',
    this.price,
    this.stock = 0,
  });

  factory ProductVariant.fromJson(dynamic json) {
    final map = asMap(json);
    return ProductVariant(
      id: asString(map['_id'] ?? map['id']),
      name: localized(map['name']),
      value: localized(map['value'] ?? map['name']),
      price: map['price'] == null ? null : asDouble(map['price']),
      stock: asInt(map['stock']),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? salePrice;
  final List<String> images;
  final int stock;
  final List<String> sizes;
  final List<ProductVariant> variants;
  final bool featured;
  final bool newArrival;
  final bool bestSeller;
  final String categoryId;
  final String categoryName;
  final bool isFavorite;
  final List<ProductModel> related;
  final String gender;
  final String sku;
  final double ratingAvg;
  final int ratingCount;

  const ProductModel({
    this.id = '',
    this.name = '',
    this.description = '',
    this.price = 0,
    this.salePrice,
    this.images = const [],
    this.stock = 0,
    this.sizes = const [],
    this.variants = const [],
    this.featured = false,
    this.newArrival = false,
    this.bestSeller = false,
    this.categoryId = '',
    this.categoryName = '',
    this.isFavorite = false,
    this.related = const [],
    this.gender = '',
    this.sku = '',
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });

  bool get isOnSale => salePrice != null && salePrice! > 0 && salePrice! < price;
  double get displayPrice => isOnSale ? salePrice! : price;
  bool get inStock => stock > 0;
  String get cover => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromJson(dynamic json) {
    final map = asMap(json);
    final imageList = asList(map['images']);
    final images = imageList
        .map((e) {
          if (e is String) return e;
          return asString(asMap(e)['url'] ?? asMap(e)['image']);
        })
        .where((e) => e.isNotEmpty)
        .toList();
    if (images.isEmpty) {
      final single = asString(map['image'] ?? map['imageUrl'] ?? map['cover']);
      if (single.isNotEmpty) images.add(single);
    }
    final relatedRaw = asList(map['related'] ?? map['relatedProducts']);
    final flags = asMap(map['flags']);
    final category = map['category'] is Map ? asMap(map['category']) : const <String, dynamic>{};
    return ProductModel(
      id: asString(map['_id'] ?? map['id']),
      name: localized(map['name'] ?? map['names']),
      description: localized(map['description'] ?? map['descriptions']),
      price: asDouble(map['price']),
      salePrice: map['salePrice'] == null && map['discountPrice'] == null
          ? null
          : asDouble(map['salePrice'] ?? map['discountPrice']),
      images: images,
      stock: asInt(map['stock'] ?? map['quantity']),
      sizes: asList(map['sizes']).map((e) => e.toString()).toList(),
      variants: asList(map['variants']).map(ProductVariant.fromJson).toList(),
      featured: asBool(map['featured'] ?? flags['featured'] ?? map['isFeatured']),
      newArrival: asBool(map['newArrival'] ?? flags['newArrival'] ?? map['isNew']),
      bestSeller: asBool(map['bestSeller'] ?? flags['bestSeller'] ?? map['isBestSeller']),
      categoryId: asString(
        map['categoryId'] ??
            (map['category'] is Map ? map['category']['_id'] : map['category']),
      ),
      categoryName: localized(category['name'] ?? category['names'] ?? map['categoryName']),
      isFavorite: asBool(map['isFavorite'] ?? map['favorited']),
      related: relatedRaw
          .whereType<Map>()
          .map(ProductModel.fromJson)
          .toList(),
      gender: asString(map['gender']),
      sku: asString(map['sku']),
      ratingAvg: asDouble(map['ratingAvg'] ?? map['rating']),
      ratingCount: asInt(map['ratingCount'] ?? map['reviewsCount']),
    );
  }

  ProductModel copyWith({
    bool? isFavorite,
    int? stock,
    double? ratingAvg,
    int? ratingCount,
  }) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      salePrice: salePrice,
      images: images,
      stock: stock ?? this.stock,
      sizes: sizes,
      variants: variants,
      featured: featured,
      newArrival: newArrival,
      bestSeller: bestSeller,
      categoryId: categoryId,
      categoryName: categoryName,
      isFavorite: isFavorite ?? this.isFavorite,
      related: related,
      gender: gender,
      sku: sku,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }
}

class CartItemModel {
  final String id;
  final String productId;
  final ProductModel? product;
  final String nameSnapshot;
  final String image;
  final String? variant;
  final String? size;
  final int quantity;
  final double price;

  const CartItemModel({
    this.id = '',
    this.productId = '',
    this.product,
    this.nameSnapshot = '',
    this.image = '',
    this.variant,
    this.size,
    this.quantity = 1,
    this.price = 0,
  });

  double get lineTotal => (product?.displayPrice ?? price) * quantity;
  String get displayName =>
      nameSnapshot.isNotEmpty ? nameSnapshot : (product?.name ?? productId);
  String get cover => image.isNotEmpty ? image : (product?.cover ?? '');

  factory CartItemModel.fromJson(dynamic json) {
    final map = asMap(json);
    ProductModel? product;
    if (map['productId'] is Map) {
      product = ProductModel.fromJson(map['productId']);
    } else if (map['product'] is Map) {
      product = ProductModel.fromJson(map['product']);
    }
    return CartItemModel(
      id: asString(map['_id'] ?? map['id']),
      productId: asId(map['productId'] ?? product?.id ?? map['product']),
      product: product,
      nameSnapshot: asString(
        map['nameSnapshot'] ?? map['name'] ?? product?.name,
      ),
      image: asString(map['image'] ?? product?.cover),
      variant: map['variant']?.toString(),
      size: map['size']?.toString(),
      quantity: asInt(map['quantity'], 1),
      price: asDouble(
        map['unitPrice'] ?? map['price'] ?? product?.displayPrice,
      ),
    );
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double total;

  const CartModel({this.items = const [], this.subtotal = 0, this.total = 0});

  factory CartModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    final items = asList(
      map['items'] ?? map['products'],
    ).map(CartItemModel.fromJson).toList();
    final sub = asDouble(
      map['subtotal'] ?? items.fold<double>(0, (p, e) => p + e.lineTotal),
    );
    return CartModel(
      items: items,
      subtotal: sub,
      total: asDouble(map['total'], sub),
    );
  }
}

class OrderAddress {
  final String fullName;
  final String phone;
  final String city;
  final String street;
  final String building;
  final String apartment;
  final String country;
  final String zip;
  final String line;
  final double? lat;
  final double? lng;

  const OrderAddress({
    this.fullName = '',
    this.phone = '',
    this.city = '',
    this.street = '',
    this.building = '',
    this.apartment = '',
    this.country = '',
    this.zip = '',
    this.line = '',
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'name': fullName,
    'phone': phone,
    'city': city,
    'street': street,
    'building': building,
    'apartment': apartment,
    'country': country,
    'zip': zip,
    'address': line.isNotEmpty
        ? line
        : [street, building, apartment, city].where((e) => e.isNotEmpty).join(', '),
    'line': line,
    if (lat != null) 'lat': lat,
    if (lng != null) 'lng': lng,
  };

  factory OrderAddress.fromJson(dynamic json) {
    final map = asMap(json);
    return OrderAddress(
      fullName: asString(map['fullName'] ?? map['name']),
      phone: asString(map['phone']),
      city: asString(map['city']),
      street: asString(map['street']),
      building: asString(map['building']),
      apartment: asString(map['apartment']),
      country: asString(map['country']),
      zip: asString(map['zip'] ?? map['postalCode']),
      line: asString(map['address'] ?? map['line']),
      lat: map['lat'] == null ? null : asDouble(map['lat']),
      lng: map['lng'] == null ? null : asDouble(map['lng']),
    );
  }

  String get display {
    if (line.isNotEmpty) return line;
    return [street, city, fullName].where((e) => e.isNotEmpty).join(' · ');
  }
}

class OrderModel {
  final String id;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final List<CartItemModel> items;
  final OrderAddress? address;
  final String notes;
  final String? rejectionReason;
  final double total;
  final DateTime? createdAt;
  final List<String> timeline;
  final double rating;
  final String ratingComment;

  const OrderModel({
    this.id = '',
    this.status = 'pending',
    this.paymentMethod = 'COD',
    this.paymentStatus = 'pending',
    this.items = const [],
    this.address,
    this.notes = '',
    this.rejectionReason,
    this.total = 0,
    this.createdAt,
    this.timeline = const [],
    this.rating = 0,
    this.ratingComment = '',
  });

  bool get canRate =>
      (status == 'delivered' || status == 'completed') && rating <= 0;

  factory OrderModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    final history = asList(map['timeline'] ?? map['statusHistory']);
    return OrderModel(
      id: asString(map['_id'] ?? map['id'] ?? map['orderNumber']),
      status: asString(map['status'] ?? map['orderStatus'], 'pending'),
      paymentMethod: asString(map['paymentMethod'], 'COD'),
      paymentStatus: asString(map['paymentStatus'], 'pending'),
      items: asList(map['items']).map(CartItemModel.fromJson).toList(),
      address: map['address'] == null
          ? null
          : OrderAddress.fromJson(map['address']),
      notes: asString(map['notes']),
      rejectionReason: map['rejectionReason']?.toString(),
      total: asDouble(map['total'] ?? map['grandTotal']),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
      rating: asDouble(map['rating']),
      ratingComment: asString(map['ratingComment']),
      timeline: history.map((e) {
        if (e is String) return e;
        return asString(asMap(e)['status'] ?? asMap(e)['name']);
      }).toList(),
    );
  }
}
