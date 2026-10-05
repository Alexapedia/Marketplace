import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/functions/responsive.dart';
import 'cart_btn.dart';
import 'home_search_bar.dart';
import 'notif_btn.dart';

class WideAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WideAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 12,
      title: Row(
        children: [
          Text(
            'app_name'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: context.isCompactHeight ? 14 : 16,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: HomeSearchBar(embedded: true)),
        ],
      ),
      actions: [
        if (!context.isCompactHeight) const NotifBtn(),
        const CartBtn(),
      ],
    );
  }
}
