import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/auth_bg.dart';
import 'widgets/forget_password_form.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBg(
      title: 'forgot_password_title'.tr(),
      subtitle: 'forgot_password_subtitle'.tr(),
      child: const ForgetPasswordForm(),
    );
  }
}
