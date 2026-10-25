import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/modules/pages/chat/controller/chat_cubit.dart';
import 'package:placemarket_mobile/modules/pages/chat/controller/chat_socket.dart';

class _FakeSocket implements ChatSocket {
  _FakeSocket(this.token);
  final String token;
  final handlers = <String, void Function(dynamic)>{};
  final emitted = <String>[];
  bool connectCalled = false;
  bool disposed = false;
  @override
  bool connected = false;

  @override
  void on(String event, void Function(dynamic) handler) =>
      handlers[event] = handler;
  @override
  void emit(String event, dynamic data) => emitted.add(event);

  /// What the server answers to the next acknowledged emit (null: never).
  dynamic ackReply = {'ok': true};
  final acked = <String, dynamic>{};
  @override
  void emitWithAck(String event, dynamic data, void Function(dynamic) ack) {
    emitted.add(event);
    acked[event] = data;
    if (ackReply != null) ack(ackReply);
  }

  @override
  void connect() => connectCalled = true;
  @override
  void dispose() => disposed = true;

  void serverConnects() {
    connected = true;
    handlers['connect']?.call(null);
  }

  void serverDrops(String reason) {
    connected = false;
    handlers['disconnect']?.call(reason);
  }

  void serverSends(String event, dynamic data) => handlers[event]?.call(data);
}

void main() {
  late List<_FakeSocket> sockets;
  late List<String> tokens;
  late int refreshes;
  late List<String> httpSent;
  late ChatCubit cubit;

  setUp(() {
    sockets = [];
    tokens = ['token-1'];
    refreshes = 0;
    httpSent = [];
    cubit = ChatCubit(
      socketFactory: (token) {
        final s = _FakeSocket(token);
        sockets.add(s);
        return s;
      },
      currentToken: () async => tokens.last,
      refreshToken: () async {
        refreshes++;
        tokens.add('token-${tokens.length + 1}');
      },
      retryDelay: Duration.zero,
      ackTimeout: const Duration(milliseconds: 50),
      postText: (orderId, text) async {
        httpSent.add(text);
        return {'_id': 'h${httpSent.length}', 'text': text};
      },
    );
  });
  tearDown(() => cubit.close());

  test('connects with the stored token and joins the order chat', () async {
    await cubit.connectSocket('order-1');
    expect(sockets.single.token, 'token-1');
    expect(sockets.single.connectCalled, isTrue);
    sockets.single.serverConnects();
    expect(sockets.single.emitted, ['join']);
    expect(cubit.state.socketReady, isTrue);
  });

  test('when the server drops the socket (token expired) it reconnects '
      'with a fresh token, without leaving the screen', () async {
    await cubit.connectSocket('order-1');
    sockets.first.serverConnects();

    sockets.first.serverDrops('io server disconnect');
    await pumpEventQueue();

    expect(refreshes, 1);
    expect(sockets, hasLength(2));
    expect(sockets.first.disposed, isTrue);
    expect(sockets.last.token, 'token-2');
    expect(sockets.last.connectCalled, isTrue);
    sockets.last.serverConnects();
    expect(cubit.state.socketReady, isTrue);
  });

  test('an Unauthorized error from the server also renews the token', () async {
    await cubit.connectSocket('order-1');
    sockets.first.serverSends('error', {'message': 'Unauthorized'});
    sockets.first.serverDrops('io server disconnect');
    await pumpEventQueue();
    expect(refreshes, 1);
    expect(sockets.last.token, 'token-2');
  });

  test(
    'an expired token refused at the handshake (connect_error) is renewed',
    () async {
      await cubit.connectSocket('order-1');
      sockets.first.serverSends('connect_error', {'message': 'Unauthorized'});
      await pumpEventQueue();
      expect(refreshes, 1);
      expect(sockets.last.token, 'token-2');
      expect(sockets.last.connectCalled, isTrue);
    },
  );

  test('a connect_error that is not about auth is left to socket.io', () async {
    await cubit.connectSocket('order-1');
    sockets.first.serverSends('connect_error', 'websocket error');
    await pumpEventQueue();
    expect(refreshes, 0);
    expect(sockets, hasLength(1));
  });

  test('sending over the socket waits for the server to accept it', () async {
    await cubit.connectSocket('order-1');
    sockets.single.serverConnects();
    cubit.text.text = 'Hello';
    await cubit.send();
    expect(sockets.single.acked['message'], {
      'customOrderId': 'order-1',
      'text': 'Hello',
    });
    expect(httpSent, isEmpty);
    expect(cubit.text.text, isEmpty);
  });

  test(
    'a message the socket refuses is sent over HTTP instead of lost',
    () async {
      await cubit.connectSocket('order-1');
      sockets.single
        ..serverConnects()
        ..ackReply = {'ok': false};
      cubit.text.text = 'Hello';
      await cubit.send();
      expect(httpSent, ['Hello']);
      expect(cubit.state.messages.map((m) => m.text), ['Hello']);
    },
  );

  test('a message the socket never answers is sent over HTTP', () async {
    await cubit.connectSocket('order-1');
    sockets.single
      ..serverConnects()
      ..ackReply = null;
    cubit.text.text = 'Hello';
    await cubit.send();
    expect(httpSent, ['Hello']);
  });

  test('a network drop is left to socket.io auto-reconnect', () async {
    await cubit.connectSocket('order-1');
    sockets.first.serverConnects();
    sockets.first.serverDrops('transport close');
    await pumpEventQueue();
    expect(refreshes, 0);
    expect(sockets, hasLength(1));
    expect(cubit.state.socketReady, isFalse);
  });

  test('gives up after a few failed renewals instead of looping', () async {
    await cubit.connectSocket('order-1');
    for (var i = 0; i < 6; i++) {
      sockets.last.serverDrops('io server disconnect');
      await pumpEventQueue();
    }
    expect(sockets.length, lessThanOrEqualTo(4));
  });

  test('a message pushed by the server shows up live', () async {
    await cubit.connectSocket('order-1');
    sockets.single.serverConnects();
    sockets.single.serverSends('message', {
      '_id': 'm1',
      'text': 'Your order is on its way',
      'senderRole': 'admin',
    });
    expect(cubit.state.messages.map((m) => m.text), [
      'Your order is on its way',
    ]);
  });
}
