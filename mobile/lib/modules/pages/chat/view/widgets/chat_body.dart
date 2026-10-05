import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/components/failed_shape.dart';
import '../../../../../core/components/loading_item.dart';
import '../../../../../core/utils/constant/app_enum.dart';
import '../../controller/chat_cubit.dart';
import 'chat_bubble.dart';
import 'chat_composer.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChatCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text('chat'.tr()),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (p, n) => p.socketReady != n.socketReady,
            builder: (context, state) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Icon(
                Icons.circle,
                size: 10,
                color: state.socketReady ? Colors.green : Colors.orange,
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
                  return const LoadingItem();
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
                    icon: Icons.chat_bubble_outline,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, i) =>
                      ChatBubble(message: state.messages[i]),
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
