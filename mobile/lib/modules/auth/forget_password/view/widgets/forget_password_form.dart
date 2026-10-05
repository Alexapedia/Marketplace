import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/validate.dart';
import '../../controller/forget_password_cubit.dart';

class ForgetPasswordForm extends StatelessWidget {
  const ForgetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = ForgetPasswordCubit.get(context);
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
    );
  }
}
