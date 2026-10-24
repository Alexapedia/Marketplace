import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/address_models.dart';
import '../../controller/addresses_cubit.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, required this.cubit});

  final AddressModel address;
  final AddressesCubit cubit;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return SurfaceCard(
      color: address.isDefault ? m.accentSoft : null,
      onTap: () async {
        final ok = await context.pushNamed(
          AppRouterKeys.addressForm,
          extra: address,
        );
        if (ok == true && context.mounted) cubit.load();
      },
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 4, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: address.isDefault ? m.accentFill : m.surface2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              address.isDefault
                  ? Icons.home_rounded
                  : Icons.location_on_outlined,
              color: address.isDefault ? m.onAccentFill : m.inkMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall?.copyWith(color: m.ink),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Text(
                        'default_address'.tr(),
                        style: text.labelMedium?.copyWith(color: m.accentInk),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  address.fullName,
                  style: text.bodyMedium?.copyWith(color: m.ink),
                ),
                Text(
                  address.display,
                  style: text.bodySmall?.copyWith(color: m.inkMuted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'settings'.tr(),
            onSelected: (v) {
              if (v == 'default') cubit.setDefault(address.id);
              if (v == 'delete') cubit.remove(address.id);
            },
            itemBuilder: (_) => [
              if (!address.isDefault)
                PopupMenuItem(
                  value: 'default',
                  child: Text('set_default'.tr()),
                ),
              PopupMenuItem(value: 'delete', child: Text('delete'.tr())),
            ],
          ),
        ],
      ),
    );
  }
}
