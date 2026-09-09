import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(const ForgetPasswordState());

  static ForgetPasswordCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

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
        emit(state.copyWith(status: RequestStatus.loaded));
      },
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    return super.close();
  }
}
