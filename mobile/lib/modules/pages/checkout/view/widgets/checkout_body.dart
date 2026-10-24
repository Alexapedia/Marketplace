import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routing/app_router_keys.dart';
import '../../../../../config/theme/maison.dart';
import '../../../../../config/theme/tokens.dart';
import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/components/maison.dart';
import '../../../../../core/models/address_models.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/motion.dart';
import '../../controller/check_out_cubit.dart';

class CheckoutBody extends StatelessWidget {
  const CheckoutBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckOutCubit>();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
          child: Center(child: CircleBackButton()),
        ),
        title: Text('checkout'.tr()),
      ),
      body: BlocBuilder<CheckOutCubit, CheckOutState>(
        builder: (context, state) {
          if (state.status == RequestStatus.failed && state.addresses.isEmpty) {
            return FailedShape(msg: state.error, onTapRefresh: cubit.load);
          }
          final loading =
              state.status == RequestStatus.loading && state.addresses.isEmpty;
          if (loading) return const LoadingItem();
          final placing = state.status == RequestStatus.loading;
          final form = ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Reveal(
                child: MaisonSectionHeader(
                  title: 'delivery_details'.tr(),
                  eyebrow: 'secure_checkout'.tr(),
                  padding: const EdgeInsetsDirectional.only(bottom: 16),
                  trailing: TextButton(
                    onPressed: () async {
                      await context.pushNamed(AppRouterKeys.addresses);
                      if (context.mounted) cubit.load();
                    },
                    child: Text('manage_addresses'.tr()),
                  ),
                ),
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
                    size: const Size(240, 52),
                  ),
                )
              else
                for (var i = 0; i < state.addresses.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Reveal(
                      index: i + 1,
                      child: _AddressChoice(
                        address: state.addresses[i],
                        selected: state.selectedId == state.addresses[i].id,
                        onTap: () => cubit.select(state.addresses[i].id),
                      ),
                    ),
                  ),
              const SizedBox(height: 8),
              AppTextField(
                controller: cubit.notes,
                title: 'order_notes'.tr(),
                hintText: 'order_notes_hint'.tr(),
                maxlines: 3,
              ),
              const SizedBox(height: 16),
              const _PaymentNote(),
            ],
          );
          return Column(
            children: [
              Expanded(child: AdaptivePage(maxWidth: 640, child: form)),
              GlassSurface(
                elevated: true,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: AppButton(
                          isLoading: placing,
                          onTap: placing ? null : () => cubit.submit(context),
                          title: 'place_order'.tr(),
                          icon: Icons.lock_outline_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressChoice extends StatelessWidget {
  const _AddressChoice({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: Pressable(
        child: AnimatedContainer(
          duration: context.motion(AppDurations.fast),
          curve: AppCurves.easeOut,
          decoration: BoxDecoration(
            color: selected ? m.accentSoft : m.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? m.accent : m.line,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected ? null : AppShadows.one(m.brightness),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected ? m.accentInk : m.inkMuted,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.label,
                            style: text.titleSmall?.copyWith(color: m.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${address.fullName} · ${address.phone}',
                            style: text.bodyMedium?.copyWith(color: m.ink),
                          ),
                          Text(
                            address.display,
                            style: text.bodySmall?.copyWith(color: m.inkMuted),
                          ),
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
    );
  }
}

class _PaymentNote extends StatelessWidget {
  const _PaymentNote();

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: m.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: m.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: m.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.payments_outlined, color: m.accentInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cod'.tr(),
                  style: text.titleSmall?.copyWith(color: m.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  'checkout_cod_note'.tr(),
                  style: text.bodySmall?.copyWith(color: m.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
