import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routing/app_router_keys.dart';

 
void openProductDetails(BuildContext context, String? id) {
  final value = (id ?? '').trim();
  if (value.isEmpty) return;
  context.pushNamed(AppRouterKeys.productDetails, extra: value);
}