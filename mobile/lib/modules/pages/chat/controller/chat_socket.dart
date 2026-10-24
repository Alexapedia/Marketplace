import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/connection/concept/end_points.dart';

/// The bit of a socket.io connection the chat needs, so the reconnect logic
/// can be tested without a server.
abstract class ChatSocket {
  bool get connected;
  void on(String event, void Function(dynamic data) handler);
  void emit(String event, dynamic data);
  void connect();
  void dispose();
}

/// `/chat` namespace on the API origin, authenticated with [token].
ChatSocket ioChatSocket(String token) => _IoChatSocket(
  io.io(
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
  ),
);

class _IoChatSocket implements ChatSocket {
  _IoChatSocket(this._socket);
  final io.Socket _socket;

  @override
  bool get connected => _socket.connected;
  @override
  void on(String event, void Function(dynamic data) handler) =>
      _socket.on(event, handler);
  @override
  void emit(String event, dynamic data) => _socket.emit(event, data);
  @override
  void connect() => _socket.connect();
  @override
  void dispose() => _socket.dispose();
}
