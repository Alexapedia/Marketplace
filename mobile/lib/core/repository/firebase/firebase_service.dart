import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../push/push_notification_service.dart';
import 'store_firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool initialized = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: currentStoreFirebaseOptions,
      );
      initialized = true;
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await PushNotificationService.instance.init();
    } catch (_) {
      // Push and crash reporting stay off; the app works without them.
      initialized = false;
    }
  }
}
