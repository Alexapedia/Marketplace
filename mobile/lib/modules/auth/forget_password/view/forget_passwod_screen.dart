import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/auth_bg.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/validate.dart';
import '../controller/forget_password_cubit.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ForgetPasswordCubit.get(context);
    return AuthBg(
      child: Form(
        key: cubit.formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'forgot_password_title'.tr(),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text('forgot_password_subtitle'.tr(), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              AppTextField(
                controller: cubit.emailController,
                title: 'email'.tr(),
                prefexIcon: Icons.mail_outline,
                validator: (v) => Validate.validateEmail(v ?? ''),
              ),
              const SizedBox(height: 20),
              BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
                builder: (context, state) {
                  if (state.status == RequestStatus.loading) {
                    return const LoadingItem();
                  }
                  return AppButton(
                    onTap: cubit.submit,
                    title: 'send_reset_link'.tr(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
