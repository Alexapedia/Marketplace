import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/color_model.dart';
import '../../../../../core/utils/functions/category_icon.dart';
import '../../controller/custom_order_cubit.dart';

class CustomCategoryGrid extends StatelessWidget {
  const CustomCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final state = context.watch<CustomOrderCubit>().state;
    final colors = Theme.of(context).extension<AppColors>()!;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) {
        final c = state.categories[i];
        final on = state.categoryId == c.id;
        return Material(
          color: on ? colors.roseSoftLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => cubit.selectCategory(c.id),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: on ? colors.gold : colors.border,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categoryIcon(c.name), size: 22, color: colors.gold),
                  const SizedBox(height: 6),
                  Text(
                    c.name.isEmpty ? '—' : c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
