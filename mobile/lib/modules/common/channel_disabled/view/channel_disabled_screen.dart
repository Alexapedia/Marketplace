import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChannelDisabledScreen extends StatelessWidget {
  const ChannelDisabledScreen({super.key, this.messageKey = 'channel_disabled_mobile'});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_outlined, size: 88),
              const SizedBox(height: 24),
              Text(
                'channel_disabled_title'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(messageKey.tr(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
