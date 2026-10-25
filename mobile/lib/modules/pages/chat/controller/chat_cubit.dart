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
    Future<Object?> Function(String orderId, String text)? postText,
    this.retryDelay = const Duration(seconds: 1),
    this.ackTimeout = const Duration(seconds: 5),
  }) : _socketFactory = socketFactory ?? ioChatSocket,
       _currentToken = currentToken ?? _storedToken,
       _refreshToken = refreshToken ?? _renewSession,
       _postText = postText ?? _postTextOverHttp,
       super(const ChatState());

  final ChatSocket Function(String token) _socketFactory;
  final Future<String?> Function() _currentToken;
  final Future<void> Function() _refreshToken;

  /// Posts a text message over HTTP; the created message, or null on failure.
  final Future<Object?> Function(String orderId, String text) _postText;

  /// How long to wait for the server to accept a socket message before
  /// sending it over HTTP instead.
  final Duration ackTimeout;

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

  static Future<Object?> _postTextOverHttp(String orderId, String text) async {
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.customOrderMessages(orderId),
      body: FormData.fromMap({'text': text, 'type': 'text'}),
    );
    return response.fold<Object?>((l) {
      AppToast(l, isError: true);
      return null;
    }, (s) => unwrapData(s.response) ?? const <String, dynamic>{});
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
    if (imagePath == null) {
      text.clear();
      // The server broadcasts an accepted message back to this room, so it
      // shows up through the socket; HTTP covers a refused or silent socket.
      if (await _sendOverSocket(orderId, bodyText)) return;
      final sent = await _postText(orderId, bodyText);
      if (sent != null) {
        _append(sent);
      } else if (!isClosed && text.text.isEmpty) {
        text.text = bodyText;
      }
      return;
    }
    // Images always go over HTTP.
    final form = FormData.fromMap({
      if (bodyText.isNotEmpty) 'text': bodyText,
      'type': 'image',
    });
    form.files.add(
      MapEntry(
        'files',
        await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      ),
    );
    text.clear();
    final response = await sl.get<ApiConsumer>().post(
      EndPoints.customOrderMessages(orderId),
      body: form,
    );
    await response.fold((l) async => AppToast(l, isError: true), (_) async {
      await load(orderId);
    });
  }

  Future<bool> _sendOverSocket(String orderId, String bodyText) {
    final socket = _socket;
    if (socket == null || !socket.connected) return Future.value(false);
    final done = Completer<bool>();
    socket.emitWithAck(
      'message',
      {'customOrderId': orderId, 'text': bodyText},
      (ack) {
        if (!done.isCompleted) done.complete(ack is Map && ack['ok'] == true);
      },
    );
    return done.future.timeout(ackTimeout, onTimeout: () => false);
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
    if (state.orderId != orderId) emit(state.copyWith(orderId: orderId));
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
    socket.on('connect_error', (error) {
      if (!isClosed) emit(state.copyWith(socketReady: false));
      // Refused at the handshake (expired token): socket.io will not retry.
      if (_isUnauthorized(error)) {
        unawaited(_reconnectWithFreshToken(orderId, socket));
      }
    });
    socket.on('message', (data) => _append(data));
    socket.connect();
  }

  static bool _isUnauthorized(dynamic error) {
    final message = error is Map ? error['message'] : error;
    return '$message'.contains('Unauthorized');
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
