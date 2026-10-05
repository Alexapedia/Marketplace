import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../connection/concept/end_points.dart';

class TelemetryReporter {
  TelemetryReporter._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: EndPoints.baseUrl,
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      headers: {'X-Client': 'mobile'},
    ),
  );

  static String _lastKey = '';
  static DateTime? _lastAt;

  static Future<void> report({
    required String kind,
    required String message,
    String? stack,
  }) async {
    final key = '$kind:$message';
    final now = DateTime.now();
    if (_lastKey == key &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(seconds: 15)) {
      return;
    }
    _lastKey = key;
    _lastAt = now;
    try {
      await _dio.post(
        '/telemetry/events',
        data: {
          'kind': kind,
          'channel': 'mobile',
          'message': message.length > 500 ? message.substring(0, 500) : message,
          if (stack != null)
            'stack': stack.length > 4000 ? stack.substring(0, 4000) : stack,
        },
      );
    } catch (_) {}
  }
}

void installTelemetryHooks() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    previous?.call(details);
    unawaited(
      TelemetryReporter.report(
        kind: 'crash',
        message: details.exceptionAsString(),
        stack: details.stack?.toString(),
      ),
    );
  };
  final previousPlatform = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      TelemetryReporter.report(
        kind: 'crash',
        message: error.toString(),
        stack: stack.toString(),
      ),
    );
    return previousPlatform?.call(error, stack) ?? true;
  };
}
