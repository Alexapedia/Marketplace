import 'package:intl/intl.dart';

String localized(dynamic value, [String? locale]) {
  final lang =
      locale ?? (Intl.defaultLocale ?? 'en').split(RegExp(r'[_-]')).first;
  if (value == null) return '';
  if (value is String) return value;
  if (value is Map) {
    return value[lang]?.toString() ??
        value['en']?.toString() ??
        value['ar']?.toString() ??
        '';
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
