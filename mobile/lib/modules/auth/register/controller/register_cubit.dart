import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/repository/package_handler/router_handler.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/shared_preferance_utils.dart';
import '../../../../core/utils/constant/storage_key.dart';
import '../../../../config/app_controller/app_controller_cubit.dart';
import '../../../../core/models/app_models.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  static RegisterCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      autoValidateMode = AutovalidateMode.always;
      emit(state.copyWith(status: RequestStatus.failed));
      return;
    }
    emit(state.copyWith(status: RequestStatus.loading));
    final response = await sl.get<ApiConsumer>().auth(
      EndPoints.register,
      body: {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        if (phoneController.text.trim().isNotEmpty)
          'phone': phoneController.text.trim(),
      },
    );
    await response.fold(
      (l) {
        AppToast(l, isError: true);
        emit(state.copyWith(status: RequestStatus.failed));
      },
      (r) async {
        final token = extractToken(r.response);
        final user = UserModel.fromJson(r.response);
        if (token.isNotEmpty) {
          await sl.get<HandleMultiCallLocal>().saveLocalData(
            data: token,
            keyType: LocalEnumKey.accessToken,
          );
          await PreferenceUtils.setString(StorageKey.userFullName, user.name);
          await sl.get<AppControllerCubit>().exitGuestMode();
        }
        emit(state.copyWith(status: RequestStatus.loaded));
        if (context.mounted) {
          RouterHandler.navigate(
            context,
            token.isNotEmpty
                ? AppRouterKeys.navigatorBarScreen
                : AppRouterKeys.signIn,
            routerType: RouterType.goName,
          );
        }
      },
    );
  }

  void togglePassword() =>
      emit(state.copyWith(isShowPassword: !state.isShowPassword));

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    return super.close();
  }
}
