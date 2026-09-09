import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/components/failed_shape.dart';
import '../../../../core/components/image_item.dart';
import '../../../../core/components/loading_item.dart';
import '../../../../core/models/color_model.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../controller/chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit()..load(orderId),
      child: Scaffold(
        appBar: AppBar(title: Text('chat'.tr())),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.status == RequestStatus.loading) {
                    return const LoadingItem();
                  }
                  if (state.status == RequestStatus.failed) {
                    return FailedShape(
                      msg: state.error,
                      onTapRefresh: () => context.read<ChatCubit>().load(orderId),
                    );
                  }
                  if (state.messages.isEmpty) {
                    return EmptyState(
                      title: 'empty_messages'.tr(),
                      icon: Icons.chat_bubble_outline,
                    );
                  }
                  final gold = Theme.of(context).extension<AppColors>()!.gold;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, i) {
                      final m = state.messages[i];
                      final mine = m.isMine || m.senderRole == 'customer';
                      return Align(
                        alignment: mine
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: mine
                                ? gold.withValues(alpha: 0.18)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m.text.isNotEmpty) Text(m.text),
                              ...m.images.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: ImageItem(
                                    e,
                                    width: 160,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.read<ChatCubit>().pickImage(),
                      icon: const Icon(Icons.photo_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: context.read<ChatCubit>().text,
                        decoration: InputDecoration(hintText: 'type_message'.tr()),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.read<ChatCubit>().send(),
                      icon: Icon(
                        Icons.send_rounded,
                        color: Theme.of(context).extension<AppColors>()!.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
