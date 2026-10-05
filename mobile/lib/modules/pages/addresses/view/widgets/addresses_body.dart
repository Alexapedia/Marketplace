import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/addresses_cubit.dart';
import 'address_card.dart';

class AddressesBody extends StatelessWidget {
  const AddressesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CircleBackButton(),
        title: Text('my_addresses'.tr()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ok = await context.pushNamed(AppRouterKeys.addressForm);
          if (ok == true && context.mounted) {
            context.read<AddressesCubit>().load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<AddressesCubit, AddressesState>(
          builder: (context, state) {
            if (state.status == RequestStatus.failed) {
              return FailedShape(
                msg: state.error,
                onTapRefresh: () => context.read<AddressesCubit>().load(),
              );
            }
            if (state.status != RequestStatus.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.items.isEmpty) {
              return EmptyState(
                title: 'no_addresses'.tr(),
                subtitle: 'no_addresses_hint'.tr(),
                icon: Icons.location_on_outlined,
                action: AppButton(
                  onTap: () => context.pushNamed(AppRouterKeys.addressForm),
                  title: 'add_address'.tr(),
                  size: const Size(220, 48),
                ),
              );
            }
            final cubit = context.read<AddressesCubit>();
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  AddressCard(address: state.items[i], cubit: cubit),
            );
          },
        ),
      ),
    );
  }
}
