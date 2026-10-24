import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/utils/functions/category_icon.dart';
import '../../controller/custom_order_cubit.dart';

class CustomCategoryGrid extends StatelessWidget {
  const CustomCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final state = context.watch<CustomOrderCubit>().state;
    final m = context.maison;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, i) {
        final c = state.categories[i];
        final on = state.categoryId == c.id;
        return Material(
          color: on ? m.accentSoft : m.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => cubit.selectCategory(c.id),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: on ? m.accent : m.line, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categoryIcon(c.name), size: 24, color: m.accentInk),
                  const SizedBox(height: 6),
                  Text(
                    c.name.isEmpty ? '—' : c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: m.ink),
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
