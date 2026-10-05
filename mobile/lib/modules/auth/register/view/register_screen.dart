import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/auth_bg.dart';
import 'widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBg(
      title: 'register'.tr(),
      subtitle: 'register_subtitle'.tr(),
      belowSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('have_account'.tr()),
          TextButton(
            onPressed: () => context.goNamed(AppRouterKeys.signIn),
            child: Text('login'.tr()),
          ),
        ],
      ),
      child: const RegisterForm(),
    );
  }
}
