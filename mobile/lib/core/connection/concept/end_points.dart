import 'dart:io';

import 'package:flutter/foundation.dart';

class EndPoints {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kDebugMode && Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://127.0.0.1:3000/api/v1';
  }

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String firebaseAuth = '/auth/firebase';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/me';

  static const String ads = '/ads';
  static const String home = '/home';
  static const String analyticsVisit = '/analytics/visit';
  static const String appConfig = '/app/config';
  static const String appVersion = '/app/version';

  static const String categories = '/categories';
  static String category(String id) => '/categories/$id';

  static const String products = '/products';
  static String product(String id) => '/products/$id';

  static const String customFields = '/custom-fields';

  static const String favorites = '/favorites';
  static String favorite(String productId) => '/favorites/$productId';

  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItem(String itemId) => '/cart/items/$itemId';

  static const String orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  static const String customOrders = '/custom-orders';
  static String customOrder(String id) => '/custom-orders/$id';
  static String confirmCustomOrder(String id) => '/custom-orders/$id/confirm';
  static String rejectCustomOrder(String id) => '/custom-orders/$id/reject';
  static String customOrderMessages(String id) => '/custom-orders/$id/messages';

  static const String notifications = '/notifications';
  static String readNotification(String id) => '/notifications/$id/read';

  static String get origin {
    return baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
  }

  static String media(String path) {
    final value = path.trim();
    if (value.isEmpty) return value;
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('assets/') ||
        value.startsWith('file:')) {
      return value;
    }
    if (value.startsWith('/')) return '$origin$value';
    return '$origin/$value';
  }

  static const String uploads = '/uploads';

  static const String reviews = '/reviews';
  static const String reviewHighlights = '/reviews/highlights';

  static const String addresses = '/addresses';
  static String address(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';
}
