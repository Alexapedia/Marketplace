import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/repository/firebase/firebase_service.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/login_cubit.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = LoginCubit.get(context);
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Form(
      key: cubit.formKey,
      autovalidateMode: cubit.autoValidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: cubit.emailController,
            title: 'email'.tr(),
            hintText: 'email'.tr(),
            prefexIcon: Icons.mail_outline_rounded,
            validator: (v) => Validate.validateEmail(v ?? ''),
          ),
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              return AppTextField(
                controller: cubit.passwordController,
                title: 'password'.tr(),
                hintText: 'password'.tr(),
                obscureText: state.isShowPassword,
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                prefexIcon: Icons.lock_outline_rounded,
                suffixIcon: state.isShowPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onTap: cubit.togglePassword,
                validator: (v) => Validate.notEmpty(v ?? ''),
              );
            },
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () =>
                  context.pushNamed(AppRouterKeys.forgetPassword),
              child: Text(
                'forgot_password'.tr(),
                style: TextStyle(color: gold, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 4),
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              if (state.loginStatus == RequestStatus.loading) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: LoadingItem(),
                );
              }
              return AppButton(
                onTap: () => cubit.login(context),
                title: 'login'.tr(),
                tag: 'auth-login-btn',
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or'.tr()),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            onTap: () => cubit.continueAsGuest(context),
            title: 'continue_as_guest'.tr(),
            isOutlined: true,
          ),
          const SizedBox(height: 10),
          AppButton(
            onTap: FirebaseService.initialized
                ? () => cubit.googleSignIn(context)
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('google_unavailable'.tr())),
                    ),
            title: 'continue_with_google'.tr(),
            isOutlined: true,
            icon: Icons.g_mobiledata_rounded,
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 10),
            AppButton(
              onTap: () => cubit.appleSignIn(context),
              title: 'continue_with_apple'.tr(),
              isOutlined: true,
              icon: Icons.apple,
            ),
          ],
        ],
      ),
    );
  }
}
