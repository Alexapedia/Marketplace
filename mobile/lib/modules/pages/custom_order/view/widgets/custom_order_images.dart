import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../controller/custom_order_cubit.dart';

class CustomOrderImages extends StatelessWidget {
  const CustomOrderImages({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CustomOrderCubit>();
    final state = context.watch<CustomOrderCubit>().state;
    final m = context.maison;
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
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
              PositionedDirectional(
                top: 2,
                end: 2,
                child: IconButton(
                  tooltip: 'remove'.tr(),
                  onPressed: () => cubit.removeImage(e.key),
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  icon: const CircleAvatar(
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
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: m.accent.withValues(alpha: 0.6)),
              color: m.accentSoft,
            ),
            child: Icon(Icons.add_a_photo_outlined, color: m.accentInk),
          ),
        ),
      ],
    );
  }
}
