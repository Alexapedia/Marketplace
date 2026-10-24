import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/safe_emit.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> with SafeEmitMixin<ForgetPasswordState> {
  ForgetPasswordCubit() : super(const ForgetPasswordState());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.forgotPassword,
      body: {'email': emailController.text.trim()},
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (_) {
        AppToast('reset_sent');
        emit(state.copyWith(status: RequestStatus.loaded, step: ForgetPasswordStep.reset));
      },
    );
  }

  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) return;
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.resetPassword,
      body: {
        'token': codeController.text.trim(),
        'password': passwordController.text,
      },
    );
    response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (_) {
        AppToast('reset_done');
        emit(state.copyWith(status: RequestStatus.loaded, done: true));
      },
    );
  }

  void backToEmail() {
    codeController.clear();
    passwordController.clear();
    emit(state.copyWith(status: RequestStatus.init, step: ForgetPasswordStep.email));
  }

  @override
  Future<void> close() {
    emailController.dispose();
    codeController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
