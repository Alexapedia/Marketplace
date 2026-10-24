import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/components/failed_shape.dart';

class ChannelDisabledScreen extends StatelessWidget {
  const ChannelDisabledScreen({
    super.key,
    this.messageKey = 'channel_disabled_mobile',
  });

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.storefront_outlined,
            title: 'channel_disabled_title'.tr(),
            subtitle: messageKey.tr(),
          ),
        ),
      ),
    );
  }
}
