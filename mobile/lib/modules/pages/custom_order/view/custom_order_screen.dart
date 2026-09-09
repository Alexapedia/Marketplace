import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/custom_order_cubit.dart';

class CustomOrderScreen extends StatelessWidget {
  const CustomOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CustomOrderCubit()..loadCategories(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return Scaffold(
      appBar: AppBar(title: Text('custom_order'.tr())),
      body: BlocBuilder<CustomOrderCubit, CustomOrderState>(
        builder: (context, state) {
          if (state.status == RequestStatus.loading) return const LoadingItem();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('pick_category'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: state.categories
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c.name),
                        selected: state.categoryId == c.id,
                        onSelected: (_) => cubit.selectCategory(c.id),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: cubit.desc,
                title: 'description'.tr(),
                maxlines: 4,
              ),
              if (state.fields.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('custom_fields'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
                ...state.fields.map(
                  (f) => AppTextField(
                    controller: cubit.fieldCtrls[f.name] ?? TextEditingController(),
                    title: '${f.label}${f.required ? ' *' : ''}',
                    hintText: f.placeholder,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text('upload_images'.tr(), style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...state.images.map(
                    (p) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(p), width: 84, height: 84, fit: BoxFit.cover),
                    ),
                  ),
                  InkWell(
                    onTap: cubit.pickImages,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold),
                      ),
                      child: Icon(Icons.add_a_photo_outlined, color: gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (state.submitStatus == RequestStatus.loading)
                const LoadingItem()
              else
                AppButton(
                  onTap: () => cubit.submit(context),
                  title: 'submit_custom_order'.tr(),
                ),
            ],
          );
        },
      ),
    );
  }
}
