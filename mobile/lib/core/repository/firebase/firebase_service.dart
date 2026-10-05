import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../firebase_options.dart';
import '../push/push_notification_service.dart';

class FirebaseService {
  FirebaseService._();

  static bool initialized = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
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
    } catch (e, st) {
      initialized = false;
      debugPrint('Firebase init skipped: $e\n$st');
    }
  }
}
