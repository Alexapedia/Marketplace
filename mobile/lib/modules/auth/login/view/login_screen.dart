import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/app_router_keys.dart';
import '../../../../core/components/auth_bg.dart';
import 'widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBg(
      title: 'sign_in'.tr(),
      subtitle: 'sign_in_subtitle'.tr(),
      belowSheet: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('no_account'.tr()),
          TextButton(
            onPressed: () => context.pushNamed(AppRouterKeys.signUp),
            child: Text('sign_up'.tr()),
          ),
        ],
      ),
      child: const LoginForm(),
    );
  }
}
