import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/connection/concept/end_points.dart';
import '../../../../core/connection/interfaces/api_consumer.dart';
import '../../../../core/models/custom_order_models.dart';
import '../../../../core/utils/constant/app_enum.dart';
import '../../../../core/utils/functions/app_toast.dart';
import '../../../../core/utils/functions/handle_multi_callback.dart';
import '../../../../core/utils/functions/json_helpers.dart';
import '../../../../core/utils/functions/service_locator.dart';
import '../../../../core/utils/functions/safe_emit.dart';

import 'chat_socket.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> with SafeEmitMixin<ChatState> {
  ChatCubit({
    ChatSocket Function(String token)? socketFactory,
    Future<String?> Function()? currentToken,
    Future<void> Function()? refreshToken,
    this.retryDelay = const Duration(seconds: 1),
  }) : _socketFactory = socketFactory ?? ioChatSocket,
       _currentToken = currentToken ?? _storedToken,
       _refreshToken = refreshToken ?? _renewSession,
       super(const ChatState());

  final ChatSocket Function(String token) _socketFactory;
  final Future<String?> Function() _currentToken;
  final Future<void> Function() _refreshToken;

  /// Pause before reconnecting with a renewed token.
  final Duration retryDelay;

  /// Renewals in a row without a successful connect before giving up.
  static const _maxRenewals = 3;

  final text = TextEditingController();
  ChatSocket? _socket;
  String? _myId;
  int _renewals = 0;

  static Future<String?> _storedToken() => sl
      .get<HandleMultiCallLocal>()
      .getLocalData(keyType: LocalEnumKey.accessToken);

  /// Any authenticated call: on 401 the API client refreshes and stores a new
  /// access token.
  static Future<void> _renewSession() async {
    await sl.get<ApiConsumer>().get(EndPoints.me);
  }

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
        connectSocket(orderId);
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

  /// Opens the live chat. The server drops the socket when its access token
  /// expires (and rejects an expired one), and socket.io does not retry after
  /// a server-side drop, so renew the token and connect again.
  @visibleForTesting
  Future<void> connectSocket(String orderId) async {
    _socket?.dispose();
    _socket = null;
    final token = await _currentToken();
    if (isClosed || token == null || token.isEmpty) return;
    final socket = _socketFactory(token);
    _socket = socket;
    socket.on('connect', (_) {
      _renewals = 0;
      socket.emit('join', {'customOrderId': orderId});
      if (!isClosed) emit(state.copyWith(socketReady: true));
    });
    socket.on('disconnect', (reason) {
      if (!isClosed) emit(state.copyWith(socketReady: false));
      if (reason == 'io server disconnect') {
        unawaited(_reconnectWithFreshToken(orderId, socket));
      }
    });
    socket.on('connect_error', (_) {
      if (!isClosed) emit(state.copyWith(socketReady: false));
    });
    socket.on('message', (data) => _append(data));
    socket.connect();
  }

  Future<void> _reconnectWithFreshToken(String orderId, ChatSocket from) async {
    if (isClosed || !identical(_socket, from) || _renewals >= _maxRenewals) {
      return;
    }
    _renewals++;
    await Future<void>.delayed(retryDelay);
    if (isClosed || !identical(_socket, from)) return;
    await _refreshToken();
    if (isClosed || !identical(_socket, from)) return;
    await connectSocket(orderId);
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
