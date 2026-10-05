import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/register_cubit.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);
    return Form(
      key: cubit.formKey,
      autovalidateMode: cubit.autoValidateMode,
      child: Column(
        children: [
          AppTextField(
            controller: cubit.nameController,
            title: 'name'.tr(),
            prefexIcon: Icons.person_outline,
            validator: (v) => Validate.notEmpty(v ?? ''),
          ),
          AppTextField(
            controller: cubit.emailController,
            title: 'email'.tr(),
            prefexIcon: Icons.mail_outline,
            validator: (v) => Validate.validateEmail(v ?? ''),
          ),
          AppTextField(
            controller: cubit.phoneController,
            title: 'phone'.tr(),
            textInputType: TextInputType.phone,
            prefexIcon: Icons.phone_outlined,
          ),
          BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              return AppTextField(
                controller: cubit.passwordController,
                title: 'password'.tr(),
                obscureText: state.isShowPassword,
                prefexIcon: Icons.lock_outline,
                suffixIcon: Icons.visibility_outlined,
                onTap: cubit.togglePassword,
                validator: (v) => Validate.validatePassword(v ?? ''),
              );
            },
          ),
          AppTextField(
            controller: cubit.confirmController,
            title: 'confirm_password'.tr(),
            obscureText: true,
            prefexIcon: Icons.lock_outline,
            validator: (v) => Validate.confirmPassword(
              cubit.passwordController.text,
              v ?? '',
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<RegisterCubit, RegisterState>(
            builder: (context, state) {
              if (state.status == RequestStatus.loading) {
                return const LoadingItem();
              }
              return AppButton(
                onTap: () => cubit.register(context),
                title: 'register'.tr(),
              );
            },
          ),
        ],
      ),
    );
  }
}
