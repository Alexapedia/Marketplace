import '../utils/constant/app_string.dart';
import '../utils/functions/camil_case.dart';

const _kKnownFields = {
  'error',
  'detail',
  'message',
  'statusCode',
  'statusMessage',
  'non_field_errors',
  'messages',
  'email',
  'phone',
  'username',
  'errors',
  'success',
};

class ErrorHandlerModel {
  int? statusCode;
  String? statusMessage;
  String? detail;
  String? message;
  String? error;
  final Map<String, List<String>> fieldErrors;

  ErrorHandlerModel({
    this.statusCode,
    this.statusMessage,
    this.detail,
    this.message,
    this.error,
    this.fieldErrors = const {},
  });

  factory ErrorHandlerModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> fieldErrors = {};
    final errors = json['errors'];
    if (errors is Map) {
      for (final entry in errors.entries) {
        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          fieldErrors[entry.key.toString()] = value
              .map((e) => e.toString())
              .toList();
        } else if (value is String && value.isNotEmpty) {
          fieldErrors[entry.key.toString()] = [value];
        }
      }
    }
    for (final entry in json.entries) {
      if (_kKnownFields.contains(entry.key)) continue;
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        fieldErrors[entry.key] = value.map((e) => e.toString()).toList();
      } else if (value is String && value.isNotEmpty) {
        fieldErrors[entry.key] = [value];
      }
    }

    return ErrorHandlerModel(
      error: json['error']?.toString(),
      statusCode: json['statusCode'] is int ? json['statusCode'] as int : null,
      statusMessage: json['statusMessage']?.toString(),
      detail: json['detail']?.toString(),
      message: json['message']?.toString(),
      fieldErrors: fieldErrors,
    );
  }

  String get firstErrorMessage {
    if (error != null && error!.isNotEmpty) return error!;
    if (detail != null && detail!.isNotEmpty) return detail!;
    if (message != null && message!.isNotEmpty) return message!;
    if (fieldErrors.isNotEmpty) {
      return fieldErrors.entries
          .map((e) => '${e.key}: ${e.value.first}')
          .join('\n');
    }
    if (statusMessage != null && statusMessage!.isNotEmpty) {
      return statusMessage!;
    }
    return AppString.unexpectedError;
  }

  String get allFieldErrors {
    if (fieldErrors.isEmpty) return firstErrorMessage.toCamelCase;
    return fieldErrors.entries
        .map((e) => '${e.key.toCamelCase}: ${e.value.join(', ')}'.toCamelCase)
        .join('\n');
  }
}
