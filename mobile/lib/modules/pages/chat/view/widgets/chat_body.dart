import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/maison.dart';
import '../../../../../core/components/adaptive_page.dart';
import '../../../../../core/components/circle_back_button.dart';
import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/skeleton_placeholders.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/chat_cubit.dart';
import 'chat_composer.dart';
import 'chat_message_list.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
          child: Center(child: CircleBackButton()),
        ),
        title: Text('chat'.tr()),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (p, n) => p.socketReady != n.socketReady,
            builder: (context, state) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: ExcludeSemantics(
                child: Icon(
                  Icons.circle,
                  size: 10,
                  color: state.socketReady
                      ? context.maison.success
                      : context.maison.inkMuted,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.status == RequestStatus.loading) {
                  return const SkeletonList(itemCount: 5, itemHeight: 64);
                }
                if (state.status == RequestStatus.failed) {
                  return FailedShape(
                    msg: state.error,
                    onTapRefresh: () => cubit.load(orderId),
                  );
                }
                if (state.messages.isEmpty) {
                  return EmptyState(
                    title: 'empty_messages'.tr(),
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }
                return AdaptivePage(
                  maxWidth: 720,
                  child: ChatMessageList(messages: state.messages),
                );
              },
            ),
          ),
          const ChatComposer(),
        ],
      ),
    );
  }
}
