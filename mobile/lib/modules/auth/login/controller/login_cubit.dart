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

class LoginCubit extends Cubit<LoginState> {
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
        await _persistSession(r.response);
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

  Future<void> googleSignIn(BuildContext context) async {
    if (!FirebaseService.initialized) {
      AppToast('google_unavailable'.tr(), isError: true);
      return;
    }
    try {
      emit(state.copyWith(loginStatus: RequestStatus.loading));
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(state.copyWith(loginStatus: RequestStatus.init));
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null) throw Exception('no token');
      if (!context.mounted) return;
      await _firebaseBackend(context, idToken);
    } catch (e) {
      printState(e);
      AppToast('auth_failed'.tr(), isError: true);
      emit(state.copyWith(loginStatus: RequestStatus.failed));
    }
  }

  Future<void> appleSignIn(BuildContext context) async {
    if (!FirebaseService.initialized) {
      AppToast('apple_unavailable'.tr(), isError: true);
      return;
    }
    try {
      emit(state.copyWith(loginStatus: RequestStatus.loading));
      final provider = AppleAuthProvider();
      final userCred = await FirebaseAuth.instance.signInWithProvider(provider);
      final idToken = await userCred.user?.getIdToken();
      if (idToken == null) throw Exception('no token');
      if (!context.mounted) return;
      await _firebaseBackend(context, idToken);
    } catch (e) {
      printState(e);
      AppToast('auth_failed'.tr(), isError: true);
      emit(state.copyWith(loginStatus: RequestStatus.failed));
    }
  }

  Future<void> _firebaseBackend(BuildContext context, String idToken) async {
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.firebaseAuth,
      body: {'idToken': idToken},
    );
    await response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(loginStatus: RequestStatus.failed));
      },
      (r) async {
        await _persistSession(r.response);
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

  Future<void> _persistSession(dynamic json) async {
    final token = extractToken(json);
    final user = UserModel.fromJson(json);
    await sl.get<HandleMultiCallLocal>().saveLocalData(
      data: token,
      keyType: LocalEnumKey.accessToken,
    );
    if (user.id.isNotEmpty) {
      await sl.get<HandleMultiCallLocal>().saveLocalData(
        data: user.id,
        keyType: LocalEnumKey.userId,
      );
    }
    if (user.name.isNotEmpty) {
      await PreferenceUtils.setString(StorageKey.userFullName, user.name);
    }
    if (user.email.isNotEmpty) {
      await PreferenceUtils.setString(StorageKey.userEmail, user.email);
    }
    emit(state.copyWith(loginStatus: RequestStatus.loaded));
    await sl.get<AppControllerCubit>().exitGuestMode();
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
