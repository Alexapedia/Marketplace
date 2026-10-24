// ignore_for_file: depend_on_referenced_packages
// flutter_cache_manager is a transitive dependency of cached_network_image.
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache manager for tests: every image request fails immediately (like being
/// offline) without touching path_provider, sqflite or the network, so
/// CachedNetworkImage shows its error / fallback widget.
class OfflineCacheManager extends BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) => Stream<FileResponse>.error(Exception('offline'));

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async => null;

  @override
  Future<FileInfo?> getFileFromMemory(String key) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
