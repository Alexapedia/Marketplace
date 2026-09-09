import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../utils/constant/app_enum.dart';

class RouterHandler {
  RouterHandler._();

  static Future<T?> navigate<T>(
    BuildContext context,
    String routerName, {
    RouterType routerType = RouterType.pushName,
    Object? extra,
  }) async {
    switch (routerType) {
      case RouterType.goName:
        context.goNamed(routerName, extra: extra);
        return null;
      case RouterType.pushName:
        return await context.pushNamed<T>(routerName, extra: extra);
      case RouterType.relacementName:
        context.replaceNamed(routerName, extra: extra);
        return null;
      case RouterType.pushReplacementNamed:
        context.pushReplacementNamed(routerName, extra: extra);
        return null;
    }
  }

  static bool canPop(BuildContext context) => context.canPop();

  static void pop<T extends Object?>(BuildContext context, {T? result}) {
    context.pop<T>(result);
  }
}
