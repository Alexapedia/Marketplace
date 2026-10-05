import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/repository/firebase/firebase_service.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/constant/storage_key.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/print_state.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/shared_preferance_utils.dart';

part 'login_state.dart';
part 'login_session_mixin.dart';
part 'login_social_mixin.dart';

class LoginCubit extends Cubit<LoginState>
    with LoginSessionMixin, LoginSocialMixin {
  LoginCubit() : super(const LoginState());

  static LoginCubit get(context) => BlocProvider.of(context);

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  Future<void> login(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      autoValidateMode = AutovalidateMode.always;
      emit(state.copyWith(loginStatus: RequestStatus.failed));
      return;
    }
    emit(state.copyWith(loginStatus: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.login,
      body: {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      },
    );
    await response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loginStatus: RequestStatus.failed));
      },
      (r) async {
        await persistSession(r.response);
        if (context.mounted) {
          RouterHandler.navigate(
            context,
            AppRouterKeys.navigatorBarScreen,
            routerType: RouterType.goName,
          );
        }
      },
    );
  }

  Future<void> continueAsGuest(BuildContext context) async {
    await sl.get<AppControllerCubit>().enterGuestMode();
    if (context.mounted) {
      RouterHandler.navigate(
        context,
        AppRouterKeys.navigatorBarScreen,
        routerType: RouterType.goName,
      );
    }
  }

  void togglePassword() {
    emit(state.copyWith(isShowPassword: !state.isShowPassword));
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
