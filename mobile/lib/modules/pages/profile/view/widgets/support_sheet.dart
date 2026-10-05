import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/open_support.dart';

class SupportSheet extends StatelessWidget {
  const SupportSheet({
    super.key,
    required this.phone,
    required this.email,
  });

  final String phone;
  final String email;

  static Future<void> show(
    BuildContext context, {
    required String phone,
    required String email,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SupportSheet(phone: phone, email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'support'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'support_hint'.tr(),
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 16),
            if (phone.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: gold.withValues(alpha: 0.18),
                  child: Icon(Icons.call, color: gold),
                ),
                title: Text('call_support'.tr()),
                subtitle: Text(phone),
                onTap: () => openPhoneDialer(phone),
              ),
            if (email.isNotEmpty)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: gold.withValues(alpha: 0.18),
                  child: Icon(Icons.email_outlined, color: gold),
                ),
                title: Text('email_support'.tr()),
                subtitle: Text(email),
                onTap: () => openSupportEmail(email),
              ),
          ],
        ),
      ),
    );
  }
}
