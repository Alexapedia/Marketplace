import 'package:intl/intl.dart';

String localized(dynamic value, [String? locale]) {
  final lang = (locale ?? Intl.getCurrentLocale()).split(RegExp(r'[_-]')).first;
  if (lang.isEmpty) return _localized(value, 'en');
  return _localized(value, lang);
}

String _localized(dynamic value, String lang) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    final direct = value[lang]?.toString() ?? '';
    if (direct.isNotEmpty) return direct;
    final en = value['en']?.toString() ?? '';
    if (en.isNotEmpty) return en;
    final ar = value['ar']?.toString() ?? '';
    if (ar.isNotEmpty) return ar;
    for (final v in value.values) {
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return '';
  }
  return value.toString();
}

Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> asList(dynamic value) {
  if (value is List) return value;
  if (value is Map) {
    final items = value['items'] ?? value['data'];
    if (items is List) return items;
  }
  return const [];
}

double asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value?.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}

String asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

String asId(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is Map) {
    return asString(value['_id'] ?? value['id'], fallback);
  }
  return asString(value, fallback);
}

dynamic unwrapData(dynamic json) {
  if (json is Map && json.containsKey('data')) return json['data'];
  return json;
}

String extractToken(dynamic json) {
  final data = unwrapData(json);
  final map = asMap(data);
  return asString(
    map['token'] ?? map['accessToken'] ?? map['access'] ?? json?['token'],
  );
}
