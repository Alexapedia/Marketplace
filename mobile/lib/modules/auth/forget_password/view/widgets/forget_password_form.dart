import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/repository/package_handler/router_handler.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/forget_password_cubit.dart';

class ForgetPasswordForm extends StatefulWidget {
  const ForgetPasswordForm({super.key});

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final cubit = ForgetPasswordCubit.get(context);
    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listenWhen: (a, b) => !a.done && b.done,
      listener: (context, state) => RouterHandler.navigate(
        context,
        AppRouterKeys.signIn,
        routerType: RouterType.goName,
      ),
      builder: (context, state) {
        final loading = state.status == RequestStatus.loading;
        if (state.step == ForgetPasswordStep.email) {
          return Form(
            key: cubit.formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: cubit.emailController,
                  title: 'email'.tr(),
                  prefexIcon: Icons.mail_outline,
                  validator: (v) => Validate.validateEmail(v ?? ''),
                ),
                const SizedBox(height: 12),
                if (loading)
                  const LoadingItem()
                else
                  AppButton(onTap: cubit.submit, title: 'send_reset_link'.tr()),
              ],
            ),
          );
        }
        return Form(
          key: cubit.resetFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'reset_code_hint'.tr(args: [cubit.emailController.text.trim()]),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: cubit.codeController,
                title: 'reset_code'.tr(),
                prefexIcon: Icons.key_outlined,
                textInputType: TextInputType.visiblePassword,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'can_not_be_empty'.tr() : null,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: cubit.passwordController,
                title: 'new_password'.tr(),
                prefexIcon: Icons.lock_outline,
                obscureText: _hidePassword,
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                suffixIconWidget: IconButton(
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (v) => Validate.validatePassword(v ?? ''),
              ),
              const SizedBox(height: 12),
              if (loading)
                const LoadingItem()
              else
                AppButton(
                  onTap: cubit.resetPassword,
                  title: 'reset_password'.tr(),
                ),
              TextButton(
                onPressed: loading ? null : cubit.backToEmail,
                child: Text('resend_code'.tr()),
              ),
            ],
          ),
        );
      },
    );
  }
}
