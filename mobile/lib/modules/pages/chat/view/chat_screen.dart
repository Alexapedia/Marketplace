import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/chat_cubit.dart';
import 'widgets/chat_body.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit()..load(orderId),
      child: ChatBody(orderId: orderId),
    );
  }
}
