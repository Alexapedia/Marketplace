import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:placemarket_mobile/core/connection/implementation/dio_consumer.dart';
import 'package:placemarket_mobile/core/utils/constant/storage_key.dart';

import 'support/test_locator.dart';

void main() {
  late TestServer server;

  tearDown(() async {
    await server.stop();
    await tearDownTestLocator();
  });

  test('401 then successful refresh retries the request with the new token',
      () async {
    await setUpTestLocator(
        secure: {StorageKey.accessToken: 'old', StorageKey.refershToken: 'r1'});
    server = await TestServer.start((req, body) {
      if (req.uri.path.endsWith('/auth/refresh')) {
        return (
          status: 201,
          body: '{"success":true,"data":{"accessToken":"new","refreshToken":"r2"}}'
        );
      }
      if (req.headers.value('authorization') == 'Bearer new') {
        return (status: 200, body: '{"success":true,"data":[]}');
      }
      return (status: 401, body: '{"success":false}');
    });

    final consumer = DioConsumer(client: Dio());
    final result = await consumer.get('/orders');

    expect(result.isRight(), isTrue);
    final orderCalls =
        server.requests.where((r) => r.path.endsWith('/orders')).toList();
    expect(orderCalls.length, 2);
    expect(orderCalls.first.auth, 'Bearer old');
    expect(orderCalls.last.auth, 'Bearer new');
    expect(server.requests.where((r) => r.path.endsWith('/auth/refresh')).length, 1);

    const storage = FlutterSecureStorage();
    expect(await storage.read(key: StorageKey.accessToken), 'new');
    expect(await storage.read(key: StorageKey.refershToken), 'r2');
  });

  for (final status in [500, 503]) {
    test('refresh failing with $status keeps the session', () async {
      await setUpTestLocator(
          secure: {StorageKey.accessToken: 'old', StorageKey.refershToken: 'r1'});
      server = await TestServer.start((req, body) {
        if (req.uri.path.endsWith('/auth/refresh')) {
          return (status: status, body: '{"success":false}');
        }
        return (status: 401, body: '{"success":false}');
      });

      final consumer = DioConsumer(client: Dio());
      final result = await consumer.get('/orders');

      expect(result.isLeft(), isTrue);
      const storage = FlutterSecureStorage();
      expect(await storage.read(key: StorageKey.accessToken), 'old');
      expect(await storage.read(key: StorageKey.refershToken), 'r1');
    });
  }

  test('401 then refresh returns 401 clears the session', () async {
    await setUpTestLocator(
        secure: {StorageKey.accessToken: 'old', StorageKey.refershToken: 'r1'});
    server = await TestServer.start((req, body) =>
        (status: 401, body: '{"success":false}'));

    final consumer = DioConsumer(client: Dio());
    final result = await consumer.get('/orders');

    expect(result.isLeft(), isTrue);
    const storage = FlutterSecureStorage();
    expect(await storage.read(key: StorageKey.accessToken), isNull);
    expect(await storage.read(key: StorageKey.refershToken), isNull);
  });
}
