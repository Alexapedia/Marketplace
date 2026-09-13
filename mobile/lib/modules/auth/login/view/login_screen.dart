import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_logo.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/auth_bg.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/components/text_with_hero.dart';
import '../../../../core/repository/firebase/firebase_service.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/validate.dart';
import '../controller/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = LoginCubit.get(context);

    return AuthBg(
      child: Form(
        key: cubit.formKey,
        autovalidateMode: cubit.autoValidateMode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              if (Navigator.of(context).canPop())
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    const AppLogo(height: 88),
                    const SizedBox(height: 18),
                    HeroText(
                      tag: 'login',
                      child: Text(
                        'sign_in'.tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'sign_in_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),
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
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      context.pushNamed(AppRouterKeys.forgetPassword),
                  child: Text('forgot_password'.tr()),
                ),
              ),
              const SizedBox(height: 8),
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
                    tag: 'login_btn',
                  );
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                onTap: () => cubit.continueAsGuest(context),
                title: 'continue_as_guest'.tr(),
                isOutlined: true,
              ),
              const SizedBox(height: 20),
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
              if (FirebaseService.initialized)
                AppButton(
                  onTap: () => cubit.googleSignIn(context),
                  title: 'continue_with_google'.tr(),
                  isOutlined: true,
                  icon: Icons.g_mobiledata_rounded,
                )
              else
                AppButton(
                  onTap: () =>
                      ScaffoldMessenger.of(context).showSnackBar(
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('no_account'.tr()),
                  TextButton(
                    onPressed: () => context.pushNamed(AppRouterKeys.signUp),
                    child: Text('sign_up'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
