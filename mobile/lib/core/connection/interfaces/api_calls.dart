import 'package:dartz/dartz.dart';

import '../../models/api_model.dart';

abstract class ApisCalls {
  Future<Either<String, ApiModel>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
  Future<Either<String, ApiModel>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool formDataIsEnabled = false,
  });
  Future<Either<String, ApiModel>> auth(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });
  Future<Either<String, ApiModel>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  });
  Future<Either<String, ApiModel>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
  Future<Either<String, ApiModel>> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });
}
