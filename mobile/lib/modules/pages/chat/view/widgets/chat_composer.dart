import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/glass_surface.dart';
import '../../controller/chat_cubit.dart';

/// Glass composer: photo button, pill field and an accent send disc.
class ChatComposer extends StatelessWidget {
  const ChatComposer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    final m = context.maison;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(color: m.line),
    );
    return GlassSurface(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'images'.tr(),
                onPressed: cubit.pickImage,
                icon: Icon(Icons.photo_outlined, color: m.inkMuted),
              ),
              Expanded(
                child: TextField(
                  controller: cubit.text,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'type_message'.tr(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    border: pill,
                    enabledBorder: pill,
                    focusedBorder: pill.copyWith(
                      borderSide: BorderSide(color: m.accentInk, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'send'.tr(),
                style: IconButton.styleFrom(
                  backgroundColor: m.accent,
                  foregroundColor: m.onAccent,
                  minimumSize: const Size(48, 48),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  cubit.send();
                },
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
