import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constant/app_enum.dart';
import '../constant/storage_key.dart';

class HandleMultiCallLocal {
  static const _storage = FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;
  String? _id;

  Future<void> saveLocalData({
    required String? data,
    required LocalEnumKey keyType,
  }) async {
    switch (keyType) {
      case LocalEnumKey.accessToken:
        _accessToken = data;
        if (data == null) {
          await _storage.delete(key: StorageKey.accessToken);
        } else {
          await _storage.write(key: StorageKey.accessToken, value: data);
        }
        break;
      case LocalEnumKey.refreshToken:
        _refreshToken = data;
        if (data == null) {
          await _storage.delete(key: StorageKey.refershToken);
        } else {
          await _storage.write(key: StorageKey.refershToken, value: data);
        }
        break;
      case LocalEnumKey.userId:
        _id = data;
        if (data == null) {
          await _storage.delete(key: StorageKey.userId);
        } else {
          await _storage.write(key: StorageKey.userId, value: data);
        }
        break;
    }
  }

  Future<String?> getLocalData({required LocalEnumKey keyType}) async {
    switch (keyType) {
      case LocalEnumKey.accessToken:
        _accessToken ??= await _storage.read(key: StorageKey.accessToken);
        return _accessToken;
      case LocalEnumKey.refreshToken:
        _refreshToken ??= await _storage.read(key: StorageKey.refershToken);
        return _refreshToken;
      case LocalEnumKey.userId:
        _id ??= await _storage.read(key: StorageKey.userId);
        return _id;
    }
  }

  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _id = null;
    await _storage.delete(key: StorageKey.accessToken);
    await _storage.delete(key: StorageKey.refershToken);
    await _storage.delete(key: StorageKey.userId);
  }
}
