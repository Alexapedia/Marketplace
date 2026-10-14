import 'package:dartz/dartz.dart';

import '../../connection/interfaces/api_consumer.dart';
import '../../models/pagination_meta.dart';
import 'json_helpers.dart';
import 'service_locator.dart';

class PageResult<T> {
  const PageResult(this.items, this.hasMore);
  final List<T> items;
  final bool hasMore;
}

/// GETs one page of a `{ data, meta }` list endpoint.
Future<Either<String, PageResult<T>>> fetchPage<T>(
  String path, {
  required int page,
  required T Function(dynamic json) parse,
  Map<String, dynamic> query = const {},
  int limit = 20,
}) async {
  final response = await sl.get<ApiConsumer>().get(
    path,
    queryParameters: {...query, 'page': page, 'limit': limit},
  );
  return response.map((s) {
    final data = unwrapData(s.response);
    final items = asList(data is List ? data : asMap(data)['items']).map(parse).toList();
    final meta = asMap(s.response)['meta'];
    final hasMore = meta != null
        ? () {
            final m = PaginationMeta.fromJson(meta);
            return m.page < m.totalPages;
          }()
        : items.length >= limit;
    return PageResult(items, hasMore);
  });
}
