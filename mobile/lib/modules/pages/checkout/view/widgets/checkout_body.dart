import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/check_out_cubit.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckOutCubit>();
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Scaffold(
      appBar: AppBar(
        leading: const CircleBackButton(),
        title: Text('checkout'.tr()),
      ),
      body: BlocBuilder<CheckOutCubit, CheckOutState>(
        builder: (context, state) {
          if (state.status == RequestStatus.failed && state.addresses.isEmpty) {
            return FailedShape(
              msg: state.error,
              onTapRefresh: cubit.load,
            );
          }
          final loading =
              state.status == RequestStatus.loading && state.addresses.isEmpty;
          if (loading) return const LoadingItem();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'delivery_details'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await context.pushNamed(AppRouterKeys.addresses);
                      if (context.mounted) cubit.load();
                    },
                    child: Text('manage_addresses'.tr()),
                  ),
                ],
              ),
              if (state.addresses.isEmpty)
                EmptyState(
                  title: 'no_addresses'.tr(),
                  subtitle: 'no_addresses_hint'.tr(),
                  icon: Icons.location_on_outlined,
                  action: AppButton(
                    onTap: () async {
                      await context.pushNamed(AppRouterKeys.addressForm);
                      if (context.mounted) cubit.load();
                    },
                    title: 'add_address'.tr(),
                    size: const Size(220, 48),
                  ),
                )
              else
                ...state.addresses.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => cubit.select(a.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: state.selectedId == a.id
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
                                state.selectedId == a.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: gold,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text('${a.fullName} · ${a.phone}'),
                                    Text(a.display),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              AppTextField(
                controller: cubit.notes,
                title: 'order_notes'.tr(),
                hintText: 'order_notes_hint'.tr(),
                maxlines: 3,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.payments_outlined, color: gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'cod'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text('checkout_cod_note'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (state.status == RequestStatus.loading)
                const LoadingItem()
              else
                AppButton(
                  onTap: () => cubit.submit(context),
                  title: 'place_order'.tr(),
                ),
            ],
          );
        },
      ),
    );
  }
}
