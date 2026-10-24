import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/addresses_cubit.dart';
import 'address_card.dart';
import '../../../../../core/components/skeleton_placeholders.dart';

class AddressesBody extends StatelessWidget {
  const AddressesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CircleBackButton(),
        title: Text('my_addresses'.tr()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await context.pushNamed(AppRouterKeys.addressForm);
          if (ok == true && context.mounted) {
            context.read<AddressesCubit>().load();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: Text('add_address'.tr()),
      ),
      body: SafeArea(
        child: AdaptivePage(
          maxWidth: 720,
          child: BlocBuilder<AddressesCubit, AddressesState>(
            builder: (context, state) {
              if (state.status == RequestStatus.failed) {
                return FailedShape(
                  msg: state.error,
                  onTapRefresh: () => context.read<AddressesCubit>().load(),
                );
              }
              if (state.status != RequestStatus.loaded) {
                return const SkeletonList(itemHeight: 110);
              }
              if (state.items.isEmpty) {
                return EmptyState(
                  title: 'no_addresses'.tr(),
                  subtitle: 'no_addresses_hint'.tr(),
                  icon: Icons.location_on_outlined,
                  action: AppButton(
                    onTap: () => context.pushNamed(AppRouterKeys.addressForm),
                    title: 'add_address'.tr(),
                    size: const Size(240, 52),
                  ),
                );
              }
              final cubit = context.read<AddressesCubit>();
              return RefreshIndicator(
                onRefresh: () => cubit.load(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => Reveal(
                    index: i,
                    child: AddressCard(address: state.items[i], cubit: cubit),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
