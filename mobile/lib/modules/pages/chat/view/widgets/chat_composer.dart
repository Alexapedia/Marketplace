import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/color_model.dart';
import '../../controller/chat_cubit.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            IconButton(
              onPressed: cubit.pickImage,
              icon: const Icon(Icons.photo_outlined),
            ),
            Expanded(
              child: TextField(
                controller: cubit.text,
                decoration: InputDecoration(hintText: 'type_message'.tr()),
              ),
            ),
            IconButton(
              onPressed: cubit.send,
              icon: Icon(Icons.send_rounded, color: gold),
            ),
          ],
        ),
      ),
    );
  }
}
