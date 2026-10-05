import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/app_text_field.dart';
import '../../../../../core/models/color_model.dart';
import '../../../../../core/models/custom_order_models.dart';
import '../../../../../core/utils/functions/category_icon.dart';
import '../../controller/custom_order_cubit.dart';

class CustomFieldBlock extends StatelessWidget {
  const CustomFieldBlock({super.key, required this.field});
  final CustomFieldModel field;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final state = context.watch<CustomOrderCubit>().state;
    final colors = Theme.of(context).extension<AppColors>()!;
    final title =
        '${field.label.isEmpty ? field.name : field.label}${field.required ? ' *' : ''}';
    final selected = state.answers[field.key];

    Widget chips({required bool multi}) {
      if (field.options.isEmpty) {
        return AppTextField(
          controller: cubit.fieldCtrls[field.key] ?? TextEditingController(),
          title: title,
          hintText: field.placeholder,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: field.options.map((opt) {
                final on = multi
                    ? (selected is List && selected.contains(opt))
                    : selected == opt;
                return FilterChip(
                  label: Text(opt),
                  selected: on,
                  onSelected: (_) {
                    if (multi) {
                      cubit.toggleMulti(field.key, opt);
                    } else {
                      cubit.setAnswer(field.key, opt);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    Widget swatches() {
      if (field.options.isEmpty) return chips(multi: false);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: field.options.map((opt) {
                final on = selected == opt;
                final swatch = tryParseSwatch(opt) ?? colors.gold;
                return GestureDetector(
                  onTap: () => cubit.setAnswer(field.key, opt),
                  child: Tooltip(
                    message: opt,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: swatch,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border),
                        boxShadow: on
                            ? [
                                BoxShadow(
                                  color: colors.gold,
                                  spreadRadius: 2,
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    switch (field.type) {
      case 'color':
        return swatches();
      case 'dropdown':
      case 'size':
      case 'select':
      case 'choice':
        return chips(multi: false);
      case 'multi_select':
        return chips(multi: true);
      case 'boolean':
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          value: selected == true || selected == 'true',
          onChanged: (v) => cubit.setAnswer(field.key, v),
        );
      case 'textarea':
        return AppTextField(
          controller: cubit.fieldCtrls[field.key] ?? TextEditingController(),
          title: title,
          hintText: field.placeholder,
          maxlines: 4,
          textInputType: TextInputType.multiline,
        );
      case 'number':
        return AppTextField(
          controller: cubit.fieldCtrls[field.key] ?? TextEditingController(),
          title: title,
          hintText: field.placeholder,
          textInputType: TextInputType.number,
        );
      default:
        return AppTextField(
          controller: cubit.fieldCtrls[field.key] ?? TextEditingController(),
          title: title,
          hintText: field.placeholder,
        );
    }
  }
}
