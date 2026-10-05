import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/color_model.dart';
import '../../controller/custom_order_cubit.dart';

class CustomOrderImages extends StatelessWidget {
  const CustomOrderImages({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final state = context.watch<CustomOrderCubit>().state;
    final colors = Theme.of(context).extension<AppColors>()!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...state.images.asMap().entries.map(
          (e) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(e.value),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () => cubit.removeImage(e.key),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: cubit.pickImages,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.gold.withValues(alpha: 0.45)),
              color: colors.gold.withValues(alpha: 0.08),
            ),
            child: Icon(Icons.add_a_photo_outlined, color: colors.gold),
          ),
        ),
      ],
    );
  }
}
