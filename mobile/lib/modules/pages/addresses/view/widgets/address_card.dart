import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/address_models.dart';
import '../../../../../core/models/color_model.dart';
import '../../controller/addresses_cubit.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, required this.cubit});

  final AddressModel address;
  final AddressesCubit cubit;

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final ok = await context.pushNamed(
            AppRouterKeys.addressForm,
            extra: address,
          );
          if (ok == true && context.mounted) cubit.load();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: address.isDefault
                  ? gold
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                address.isDefault ? Icons.home_rounded : Icons.location_on_outlined,
                color: gold,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Text(
                            'default_address'.tr(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(address.fullName),
                    Text(
                      address.display,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
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
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('delete'.tr()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
