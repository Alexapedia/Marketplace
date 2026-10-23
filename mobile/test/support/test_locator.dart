import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:placemarket_mobile/core/connection/interfaces/api_consumer.dart';
import 'package:placemarket_mobile/core/connection/interfaces/network_info.dart';
import 'package:placemarket_mobile/core/models/api_model.dart';
import 'package:placemarket_mobile/core/utils/functions/handle_multi_callback.dart';
import 'package:placemarket_mobile/core/utils/functions/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
  @override
  Future<bool> get hasConnection async => true;
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

typedef RecordedCall = ({
  String method,
  String path,
  dynamic body,
  Map<String, dynamic>? headers,
});

/// ApiConsumer fake that records calls and answers with [postResult].
class FakeApiConsumer implements ApiConsumer {
  final List<RecordedCall> calls = [];
  Either<String, ApiModel> postResult =
      left('fake_failure');
  Either<String, ApiModel> getResult =
      right(ApiModel(response: {'data': []}, statusCode: 200));

  @override
  Future<Either<String, ApiModel>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    calls.add((method: 'GET', path: path, body: null, headers: null));
    return getResult;
  }

  @override
  Future<Either<String, ApiModel>> post(String path,
      {dynamic body,
      Map<String, dynamic>? queryParameters,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? headers}) async {
    calls.add((method: 'POST', path: path, body: body, headers: headers));
    return postResult;
  }

  @override
  Future<Either<String, ApiModel>> auth(String path,
          {Map<String, dynamic>? body,
          Map<String, dynamic>? queryParameters}) async =>
      throw UnimplementedError();
  @override
  Future<Either<String, ApiModel>> put(String path,
          {Map<String, dynamic>? body,
          Map<String, dynamic>? queryParameters}) async =>
      throw UnimplementedError();
  @override
  Future<Either<String, ApiModel>> delete(String path,
          {Map<String, dynamic>? queryParameters}) async =>
      throw UnimplementedError();
  @override
  Future<Either<String, ApiModel>> patch(String path,
          {dynamic body, Map<String, dynamic>? queryParameters}) async =>
      throw UnimplementedError();
  @override
  Either<String, ApiModel> handleResponseStatus(Response response) =>
      throw UnimplementedError();
  @override
  Exception handleDioError(DioException error) => throw UnimplementedError();
  @override
  Map<String, dynamic> handleResponseAsJson(Response<dynamic> response) =>
      throw UnimplementedError();
}

/// Resets [sl], mocks secure storage + shared prefs, and registers fakes.
/// Pass [api] to register an ApiConsumer; the real HandleMultiCallLocal
/// (backed by mocked FlutterSecureStorage) is always registered.
Future<void> setUpTestLocator({
  ApiConsumer? api,
  Map<String, String> secure = const {},
}) async {
  await sl.reset();
  SharedPreferences.setMockInitialValues({});
  FlutterSecureStorage.setMockInitialValues(Map.of(secure));
  sl.registerSingleton<NetworkInfo>(FakeNetworkInfo());
  sl.registerSingleton<HandleMultiCallLocal>(HandleMultiCallLocal());
  if (api != null) sl.registerSingleton<ApiConsumer>(api);
}

Future<void> tearDownTestLocator() => sl.reset();

typedef ServerHandler = FutureOr<({int status, String body})> Function(
    HttpRequest req, String body);

/// Local HTTP server on an ephemeral port. [redirectAllHttpTo] makes every
/// dart:io HttpClient (including DioConsumer's bare refresh Dio) connect to it
/// regardless of the URL's host/port, via HttpOverrides + connectionFactory.
class TestServer {
  TestServer._(this.server);
  final HttpServer server;
  final List<({String method, String path, String? auth, String body})>
      requests = [];

  static Future<TestServer> start(ServerHandler handler) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final ts = TestServer._(server);
    server.listen((req) async {
      final body = await utf8.decodeStream(req);
      ts.requests.add((
        method: req.method,
        path: req.uri.path,
        auth: req.headers.value('authorization'),
        body: body,
      ));
      final r = await handler(req, body);
      req.response
        ..statusCode = r.status
        ..headers.contentType = ContentType.json
        ..write(r.body);
      await req.response.close();
    });
    HttpOverrides.global = _RedirectOverrides(server.port);
    return ts;
  }

  Future<void> stop() async {
    HttpOverrides.global = null;
    await server.close(force: true);
  }
}

class _RedirectOverrides extends HttpOverrides {
  _RedirectOverrides(this.port);
  final int port;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final c = super.createHttpClient(context);
    c.connectionFactory = (uri, proxyHost, proxyPort) =>
        Socket.startConnect(InternetAddress.loopbackIPv4, port);
    return c;
  }
}
