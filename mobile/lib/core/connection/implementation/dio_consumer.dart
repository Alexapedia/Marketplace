import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../config/routing/app_router_keys.dart';
import '../../../placemarket_app.dart';
import '../../models/api_model.dart';
import '../../models/error_handler_model.dart';
import '../../repository/package_handler/router_handler.dart';
import '../../utils/constant/app_enum.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/storage_key.dart';
import '../../utils/functions/camil_case.dart';
import '../../utils/functions/handle_multi_callback.dart';
import '../../utils/functions/print_state.dart';
import '../../utils/functions/service_locator.dart';
import '../../utils/functions/shared_preferance_utils.dart';
import '../concept/end_points.dart';
import '../concept/exceptions.dart';
import '../concept/status_code.dart';
import '../interfaces/api_consumer.dart';
import '../interfaces/network_info.dart';

class DioConsumer implements ApiConsumer {
  final Dio client;

  static const _guestSafePrefixes = [
    '/app/',
    '/categories',
    '/products',
    '/custom-fields',
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/firebase',
  ];

  DioConsumer({required this.client}) {
    client.interceptors.addAll([
      _connectivityInterceptor(),
      _authInterceptor(),
    ]);

    client.options
      ..baseUrl = EndPoints.baseUrl
      ..connectTimeout = const Duration(milliseconds: 30000)
      ..receiveTimeout = const Duration(milliseconds: 30000)
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..validateStatus = (status) {
        return status != null && status < 500 && status != 401;
      };
  }

  @override
  Future<Either<String, ApiModel>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.get(path, queryParameters: queryParameters);
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool formDataIsEnabled = false,
  }) async {
    try {
      final response = await client.post(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> auth(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.post(
        path,
        queryParameters: queryParameters,
        data: body,
        options: Options(extra: {AppString.requiresTokenKey: false}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return right(
          ApiModel(
            response: handleResponseAsJson(response),
            statusCode: response.statusCode!,
          ),
        );
      }
      return left(handleError(response));
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.put(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.patch(
        path,
        queryParameters: queryParameters,
        data: body,
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await client.delete(
        path,
        queryParameters: queryParameters,
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (e) {
      printState(e);
      return left('unexpected_error'.tr());
    }
  }

  @override
  Map<String, dynamic> handleResponseAsJson(Response response) {
    if (response.data == null || response.data.toString().trim().isEmpty) {
      return {};
    }
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return jsonDecode(response.data.toString()) as Map<String, dynamic>;
  }

  @override
  Either<String, ApiModel> handleResponseStatus(Response response) {
    final status = response.statusCode ?? 0;
    if (status >= 400) {
      return left(handleError(response));
    }
    return right(
      ApiModel(response: handleResponseAsJson(response), statusCode: status),
    );
  }

  @override
  Exception handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.cancel:
        return FetchDataException();
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return NoInternetConnectionException();
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
        if (error.error is SocketException) {
          return NoInternetConnectionException();
        }
        return FetchDataException(error.message);
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        switch (code) {
          case StatusCode.badRequest:
            return BadRequestException(handleError(error.response!));
          case StatusCode.unauthorized:
          case StatusCode.forbidden:
            return UnauthorizedException();
          case StatusCode.notFound:
            return NotFoundException();
          case StatusCode.conflict:
            return ConflictException();
          case StatusCode.internalServerError:
            return InternalServerException();
          default:
            return FetchDataException();
        }
    }
  }

  String handleError(Response response) {
    try {
      final json = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : handleResponseAsJson(response);
      return ErrorHandlerModel.fromJson(json).firstErrorMessage.toCamelCase;
    } catch (_) {
      return AppString.unexpectedError;
    }
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers[AppString.headerAcceptLanguage] =
            PreferenceUtils.getString(StorageKey.lang, AppString.localeEn);
        if (options.extra[AppString.requiresTokenKey] != false) {
          final token = await sl<HandleMultiCallLocal>().getLocalData(
            keyType: LocalEnumKey.accessToken,
          );
          if (token != null && token.isNotEmpty) {
            options.headers[AppString.headerAuthorization] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        if (e.response?.statusCode == 401) {
          await _handleUnauthorized(e.requestOptions.path);
        }
        return handler.next(e);
      },
    );
  }

  Future<void> _handleUnauthorized(String path) async {
    await sl<HandleMultiCallLocal>().clear();
    await PreferenceUtils.setBool(StorageKey.isGuestMode, true);
    final isGuestSafe = _guestSafePrefixes.any(path.contains);
    if (isGuestSafe) return;
    final context = PlaceMarketApp.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      RouterHandler.navigate(
        context,
        AppRouterKeys.signIn,
        routerType: RouterType.goName,
      );
    }
  }

  InterceptorsWrapper _connectivityInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final results = await sl<NetworkInfo>().hasConnection;
          if (!results) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'no_internet'.tr(),
              ),
            );
          }
        } catch (_) {}
        handler.next(options);
      },
    );
  }
}
