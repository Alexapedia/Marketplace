import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/typography.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/utils/functions/open_support.dart';

class SupportSheet extends StatelessWidget {
  const SupportSheet({super.key, required this.phone, required this.email});

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
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    Widget row(
      IconData icon,
      String title,
      String sub,
      VoidCallback onTap,
    ) => ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 10,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: m.accentSoft, shape: BoxShape.circle),
        child: Icon(icon, color: m.accentInk, size: 20),
      ),
      title: Text(title, style: text.titleSmall?.copyWith(color: m.ink)),
      subtitle: Text(sub, style: text.bodySmall?.copyWith(color: m.inkMuted)),
      onTap: onTap,
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('support'.tr(), style: displayStyle(size: 24, color: m.ink)),
            const SizedBox(height: 10),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoldRule(width: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'support_hint'.tr(),
              style: text.bodyMedium?.copyWith(color: m.inkMuted),
            ),
            const SizedBox(height: 12),
            if (phone.isNotEmpty)
              row(
                Icons.call_outlined,
                'call_support'.tr(),
                phone,
                () => openPhoneDialer(phone),
              ),
            if (email.isNotEmpty)
              row(
                Icons.email_outlined,
                'email_support'.tr(),
                email,
                () => openSupportEmail(email),
              ),
          ],
        ),
      ),
    );
  }
}
