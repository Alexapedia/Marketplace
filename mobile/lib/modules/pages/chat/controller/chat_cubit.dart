import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState());

  final text = TextEditingController();
  io.Socket? _socket;
  String? _myId;

  Future<void> load(String orderId) async {
    emit(state.copyWith(status: RequestStatus.loading, orderId: orderId));
    _myId = await sl.get<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.userId,
    );
    final response = await sl.get<ApiConsumer>().get(
      EndPoints.customOrderMessages(orderId),
    );
    response.fold(
      (l) => emit(state.copyWith(status: RequestStatus.failed, error: l)),
      (s) {
        final data = unwrapData(s.response);
        final list = asList(
          data is List ? data : asMap(data)['items'],
        ).map((e) => ChatMessageModel.fromJson(e, myId: _myId)).toList();
        emit(
          state.copyWith(
            status: RequestStatus.loaded,
            messages: list,
            socketReady: false,
          ),
        );
        _connectSocket(orderId);
      },
    );
  }

  Future<void> send({String? imagePath}) async {
    final orderId = state.orderId;
    if (orderId.isEmpty) return;
    final bodyText = text.text.trim();
    if (bodyText.isEmpty && imagePath == null) return;
    if (imagePath == null && _socket?.connected == true) {
      text.clear();
      _socket!.emit('message', {'customOrderId': orderId, 'text': bodyText});
      return;
    }
    final form = FormData.fromMap({
      if (bodyText.isNotEmpty) 'text': bodyText,
      'type': imagePath != null ? 'image' : 'text',
    });
    if (imagePath != null) {
      form.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        ),
      );
    }
    text.clear();
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.customOrderMessages(orderId),
      body: form,
    );
    await response.fold((l) async => AppToast(l, isError: true), (_) async {
      await load(orderId);
    });
  }

  Future<void> pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) await send(imagePath: file.path);
  }

  Future<void> _connectSocket(String orderId) async {
    _socket?.dispose();
    final token = await sl.get<HandleMultiCallLocal>().getLocalData(
      keyType: LocalEnumKey.accessToken,
    );
    if (token == null || token.isEmpty) return;
    final socket = io.io(
      '${EndPoints.origin}/chat',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setPath('/socket.io')
          .setAuth({'token': token})
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableForceNew()
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );
    _socket = socket;
    socket.onConnect((_) {
      socket.emit('join', {'customOrderId': orderId});
      if (!isClosed) emit(state.copyWith(socketReady: true));
    });
    socket.onDisconnect((_) {
      if (!isClosed) emit(state.copyWith(socketReady: false));
    });
    socket.onConnectError((_) {
      if (!isClosed) emit(state.copyWith(socketReady: false));
    });
    socket.on('message', (data) => _append(data));
    socket.connect();
  }

  void _append(dynamic data) {
    if (isClosed) return;
    final msg = ChatMessageModel.fromJson(data, myId: _myId);
    if (msg.id.isNotEmpty && state.messages.any((m) => m.id == msg.id)) return;
    emit(state.copyWith(messages: [...state.messages, msg]));
  }

  @override
  Future<void> close() {
    text.dispose();
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}
