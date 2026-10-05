import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routing/app_router_keys.dart';
import '../../../firebase_options.dart';
import '../../../placemarket_app.dart';
import '../../connection/concept/end_points.dart';
import '../../connection/interfaces/api_consumer.dart';
import '../../utils/constant/app_enum.dart';
import '../../utils/constant/storage_key.dart';
import '../../utils/functions/handle_multi_callback.dart';
import '../../utils/functions/service_locator.dart';
import '../../utils/functions/shared_preferance_utils.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'orders',
    'Order updates',
    description: 'Order status and store alerts',
    importance: Importance.high,
    playSound: true,
  );

  bool _ready = false;
  Map<String, String>? _pending;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (response) {
        openFromPayload(response.payload);
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_showLocal);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => openFromData(m.data));
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _pending = _asStringMap(initial.data);
    }
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      openFromPayload(launch?.notificationResponse?.payload);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen(registerToken);
    _ready = true;
    await registerToken();
  }

  Future<void> registerToken([String? token]) async {
    try {
      final access = await sl.get<HandleMultiCallLocal>().getLocalData(
        keyType: LocalEnumKey.accessToken,
      );
      if (access == null || access.isEmpty) return;
      final fcm =
          token ?? await FirebaseMessaging.instance.getToken();
      if (fcm == null || fcm.isEmpty) return;
      await PreferenceUtils.setString(StorageKey.fcmToken, fcm);
      await sl.get<ApiConsumer>().patch(
        EndPoints.me,
        body: {'fcmToken': fcm},
      );
    } catch (e) {
      debugPrint('FCM register skipped: $e');
    }
  }

  void consumePending() {
    final pending = _pending;
    _pending = null;
    if (pending != null) {
      openFromData(pending);
    }
  }

  Future<void> _showLocal(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    if (title.isEmpty && body.isEmpty) return;
    await _plugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'default',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void openFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload);
      if (data is Map) {
        openFromData(data.map((k, v) => MapEntry('$k', '$v')));
      }
    } catch (_) {}
  }

  static void openFromData(Map<String, dynamic> data) {
    final type = '${data['type'] ?? ''}';
    final orderId = '${data['orderId'] ?? ''}';
    final customOrderId = '${data['customOrderId'] ?? ''}';
    final ctx = PlaceMarketApp.navigatorKey.currentContext;
    if (ctx == null) {
      instance._pending = _asStringMap(data);
      return;
    }
    if (type.contains('custom') && customOrderId.isNotEmpty) {
      ctx.pushNamed(AppRouterKeys.customOrderDetails, extra: customOrderId);
      return;
    }
    if (orderId.isNotEmpty) {
      ctx.pushNamed(AppRouterKeys.orderDetails, extra: orderId);
      return;
    }
    ctx.pushNamed(AppRouterKeys.notificationScreen);
  }

  static Map<String, String> _asStringMap(Map<String, dynamic> data) {
    return data.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
}
