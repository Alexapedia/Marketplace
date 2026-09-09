import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final String? message;

  const ServerException([this.message]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$message';
}

class FetchDataException extends ServerException {
  FetchDataException([String? message])
    : super(message ?? 'error_communication'.tr());
}

class BadRequestException extends ServerException {
  BadRequestException([String? message]) : super(message ?? 'bad_request'.tr());
}

class UnauthorizedException extends ServerException {
  UnauthorizedException([String? message])
    : super(message ?? 'unauthorized'.tr());
}

class NotFoundException extends ServerException {
  NotFoundException([String? message]) : super(message ?? 'request_info'.tr());
}

class ConflictException extends ServerException {
  ConflictException([String? message]) : super(message ?? 'conflict'.tr());
}

class InternalServerException extends ServerException {
  InternalServerException([String? message])
    : super(message ?? 'server_failed'.tr());
}

class NoInternetConnectionException extends ServerException {
  NoInternetConnectionException([String? message])
    : super(message ?? 'no_internet'.tr());
}
