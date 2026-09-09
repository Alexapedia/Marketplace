import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  FirebaseService._();

  static bool initialized = false;

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      initialized = true;
      try {
        await FirebaseMessaging.instance.requestPermission();
      } catch (_) {}
    } catch (e, st) {
      initialized = false;
      debugPrint('Firebase init skipped: $e\n$st');
    }
  }
}
