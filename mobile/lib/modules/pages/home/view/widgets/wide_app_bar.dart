import 'package:flutter/material.dart';

import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/utils/functions/responsive.dart';
import 'cart_btn.dart';
import 'home_search_bar.dart';
import 'notif_btn.dart';

/// Tablet / landscape header: glass bar with a centred search pill (the
/// logo lives in the navigation rail).
class WideAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WideAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      backgroundColor: Colors.transparent,
      flexibleSpace: const GlassSurface(
        edge: GlassEdge.bottom,
        child: SizedBox.expand(),
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      centerTitle: false,
      title: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: const HomeSearchBar(embedded: true),
      ),
      actions: [
        if (!context.isCompactHeight) const NotifBtn(),
        const CartBtn(),
        const SizedBox(width: 16),
      ],
    );
  }
}
