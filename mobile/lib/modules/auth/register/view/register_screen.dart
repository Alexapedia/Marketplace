import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/auth_bg.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/validate.dart';
import '../controller/register_cubit.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = RegisterCubit.get(context);
    return AuthBg(
      child: Form(
        key: cubit.formKey,
        autovalidateMode: cubit.autoValidateMode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              Text(
                'register'.tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('register_subtitle'.tr(), textAlign: TextAlign.center),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('have_account'.tr()),
                  TextButton(
                    onPressed: () => context.goNamed(AppRouterKeys.signIn),
                    child: Text('login'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
