import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/constant/storage_key.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/shared_preferance_utils.dart';
import '../../../../core/utils/functions/version_compare.dart';

part 'splash_state.dart';
part 'splash_boot_mixin.dart';

class SplashCubit extends Cubit<SplashState> with SplashBootMixin {
  SplashCubit() : super(const SplashState());
}
