import '../utils/functions/json_helpers.dart';

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 0,
  });

  factory PaginationMeta.fromJson(dynamic json) {
    final map = asMap(json);
    return PaginationMeta(
      page: asInt(map['page'], 1),
      limit: asInt(map['limit'], 20),
      total: asInt(map['total']),
      totalPages: asInt(map['totalPages']),
    );
  }
}
