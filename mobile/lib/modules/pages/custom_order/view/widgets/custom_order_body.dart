import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/app_button.dart';
import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/gold_stepper.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../../../../core/utils/functions/responsive.dart';
import '../../controller/custom_order_cubit.dart';
import 'custom_category_grid.dart';
import 'custom_field_block.dart';
import 'custom_order_images.dart';

class CustomOrderBody extends StatelessWidget {
  const CustomOrderBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blackColor,
        foregroundColor: Colors.white,
        leading: const CircleBackButton(),
        title: Text('custom_order'.tr()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(14),
          child: BlocBuilder<CustomOrderCubit, CustomOrderState>(
            builder: (context, state) {
              var done = 0;
              if (state.categoryId.isNotEmpty) done++;
              if (cubit.desc.text.trim().isNotEmpty) done++;
              if (state.images.isNotEmpty) done++;
              return GoldBarStepper(total: 3, completed: done);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CustomOrderCubit, CustomOrderState>(
          builder: (context, state) {
            if (state.status == RequestStatus.loading) {
              return const LoadingItem();
            }
            return AdaptivePage(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text(
                    'pick_category'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: context.font(16),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const CustomCategoryGrid(),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: cubit.desc,
                    title: 'description'.tr(),
                    hintText: 'custom_order_desc_hint'.tr(),
                    maxlines: 4,
                    textInputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  if (state.fields.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'custom_fields'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: context.font(16),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...state.fields.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: CustomFieldBlock(field: f),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'upload_images'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: context.font(16),
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CustomOrderImages(),
                  const SizedBox(height: 28),
                  if (state.submitStatus == RequestStatus.loading)
                    const LoadingItem()
                  else
                    AppButton(
                      onTap: () => cubit.submit(context),
                      title: 'submit_custom_order'.tr(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
