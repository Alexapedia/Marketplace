import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/validate.dart';
import '../controller/check_out_cubit.dart';

class CheckOutScreen extends StatelessWidget {
  const CheckOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckOutCubit(),
      child: const _CheckoutBody(),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckOutCubit>();
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Scaffold(
      appBar: AppBar(title: Text('checkout'.tr())),
      body: Form(
        key: cubit.formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('delivery_details'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            AppTextField(
              controller: cubit.name,
              title: 'name'.tr(),
              validator: (v) => Validate.notEmpty(v ?? ''),
            ),
            AppTextField(
              controller: cubit.phone,
              title: 'phone'.tr(),
              textInputType: TextInputType.phone,
              validator: (v) => Validate.validatePhoneNumber(v),
            ),
            AppTextField(
              controller: cubit.city,
              title: 'city'.tr(),
              validator: (v) => Validate.notEmpty(v ?? ''),
            ),
            AppTextField(
              controller: cubit.street,
              title: 'street'.tr(),
              validator: (v) => Validate.notEmpty(v ?? ''),
            ),
            AppTextField(controller: cubit.building, title: 'building'.tr()),
            AppTextField(controller: cubit.apartment, title: 'apartment'.tr()),
            AppTextField(controller: cubit.country, title: 'country'.tr()),
            AppTextField(
              controller: cubit.notes,
              title: 'order_notes'.tr(),
              hintText: 'order_notes_hint'.tr(),
              maxlines: 3,
            ),
            const SizedBox(height: 16),
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
                        Text('cod'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('checkout_cod_note'.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<CheckOutCubit, CheckOutState>(
              builder: (context, state) {
                if (state.status == RequestStatus.loading) {
                  return const LoadingItem();
                }
                return AppButton(
                  onTap: () => cubit.submit(context),
                  title: 'place_order'.tr(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
