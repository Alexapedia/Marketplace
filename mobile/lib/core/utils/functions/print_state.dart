import 'dart:developer';

import 'package:flutter/foundation.dart';

void printState(dynamic data) {
  if (kDebugMode) {
    log(data.toString());
  }
}
