import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/models/address_models.dart';
import '../../../../../core/utils/functions/app_toast.dart';
import '../../controller/addresses_cubit.dart';

class PickAddressSheet extends StatelessWidget {
  const PickAddressSheet({super.key, required this.items});

  final List<AddressModel> items;

  static Future<AddressModel?> show(BuildContext context) async {
    final cubit = AddressesCubit();
    await cubit.load();
    if (!context.mounted) {
      await cubit.close();
      return null;
    }
    if (cubit.state.items.isEmpty) {
      await cubit.close();
      AppToast('no_addresses_hint');
      if (context.mounted) {
        await context.pushNamed(AppRouterKeys.addressForm);
      }
      return null;
    }
    final picked = await showModalBottomSheet<AddressModel>(
      context: context,
      showDragHandle: true,
      builder: (_) => PickAddressSheet(items: cubit.state.items),
    );
    await cubit.close();
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shrinkWrap: true,
        children: [
          Text(
            'pick_address'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (a) => ListTile(
              leading: Icon(
                a.isDefault ? Icons.home_rounded : Icons.location_on_outlined,
              ),
              title: Text(a.label),
              subtitle: Text('${a.fullName}\n${a.display}'),
              isThreeLine: true,
              onTap: () => Navigator.pop(context, a),
            ),
          ),
        ],
      ),
    );
  }
}
