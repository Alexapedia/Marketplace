import '../utils/functions/json_helpers.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String? language;
  final String? theme;
  final String role;

  const UserModel({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.avatar,
    this.language,
    this.theme,
    this.role = 'customer',
  });

  factory UserModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    final nested = map['user'] is Map ? asMap(map['user']) : map;
    return UserModel(
      id: asString(nested['_id'] ?? nested['id']),
      name: asString(nested['name']),
      email: asString(nested['email']),
      phone: asString(nested['phone']),
      avatar: nested['avatar']?.toString(),
      language: nested['language']?.toString(),
      theme: nested['theme']?.toString(),
      role: asString(nested['role'], 'customer'),
    );
  }
}

class BannerModel {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String? link;
  final String? productId;
  final String? categoryId;

  const BannerModel({
    this.id = '',
    this.image = '',
    this.title = '',
    this.subtitle = '',
    this.link,
    this.productId,
    this.categoryId,
  });

  factory BannerModel.fromJson(dynamic json) {
    final map = asMap(json);
    return BannerModel(
      id: asString(map['_id'] ?? map['id']),
      image: asString(map['image'] ?? map['imageUrl'] ?? map['url']),
      title: localized(map['title'] ?? map['name']),
      subtitle: localized(map['subtitle'] ?? map['description']),
      link: map['link']?.toString(),
      productId: map['productId']?.toString(),
      categoryId: map['categoryId']?.toString(),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String body;
  final String image;
  final String icon;

  const OnboardingSlide({
    required this.title,
    required this.body,
    this.image = '',
    this.icon = 'shopping_bag',
  });

  factory OnboardingSlide.fromJson(dynamic json) {
    final map = asMap(json);
    return OnboardingSlide(
      title: localized(map['title']),
      body: localized(map['body'] ?? map['description']),
      image: asString(map['image']),
      icon: asString(map['icon'], 'shopping_bag'),
    );
  }
}

class AppConfigModel {
  final List<BannerModel> banners;
  final List<OnboardingSlide> onboarding;
  final Map<String, dynamic> settings;

  const AppConfigModel({
    this.banners = const [],
    this.onboarding = const [],
    this.settings = const {},
  });

  factory AppConfigModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    return AppConfigModel(
      banners: asList(map['banners']).map(BannerModel.fromJson).toList(),
      onboarding: asList(
        map['onboarding'],
      ).map(OnboardingSlide.fromJson).toList(),
      settings: asMap(map['settings']),
    );
  }
}

class AppVersionModel {
  final String minimumVersion;
  final String latestVersion;
  final bool force;
  final String storeUrl;
  final String message;

  const AppVersionModel({
    this.minimumVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.force = false,
    this.storeUrl = '',
    this.message = '',
  });

  factory AppVersionModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    final nested = map['version'] is Map ? asMap(map['version']) : map;
    return AppVersionModel(
      minimumVersion: asString(
        nested['minimumVersion'] ??
            nested['minVersion'] ??
            nested['minimum'] ??
            '0.0.0',
      ),
      latestVersion: asString(
        nested['latestVersion'] ?? nested['latest'] ?? '1.0.0',
      ),
      force: asBool(nested['force'] ?? nested['forceUpdate'], true),
      storeUrl: asString(nested['storeUrl'] ?? nested['url']),
      message: localized(nested['message']),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final String? type;
  final String? referenceId;

  const NotificationModel({
    this.id = '',
    this.title = '',
    this.body = '',
    this.isRead = false,
    this.createdAt,
    this.type,
    this.referenceId,
  });

  factory NotificationModel.fromJson(dynamic json) {
    final map = asMap(json);
    return NotificationModel(
      id: asString(map['_id'] ?? map['id']),
      title: localized(map['title']),
      body: localized(map['body'] ?? map['message']),
      isRead: asBool(map['isRead'] ?? map['read']),
      createdAt: DateTime.tryParse(asString(map['createdAt'])),
      type: map['type']?.toString(),
      referenceId: (map['referenceId'] ?? map['orderId'])?.toString(),
    );
  }
}
