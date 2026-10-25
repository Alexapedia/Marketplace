import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../../../config/routing/app_router_keys.dart';
import '../../../placemarket_app.dart';
import '../../models/api_model.dart';
import '../../models/error_handler_model.dart';
import '../../repository/package_handler/router_handler.dart';
import '../../telemetry/telemetry_reporter.dart';
import '../../utils/constant/app_enum.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/storage_key.dart';
import '../../utils/functions/camil_case.dart';
import '../../utils/functions/handle_multi_callback.dart';
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
    '/home',
    '/ads',
    '/analytics',
    '/categories',
    '/products',
    '/custom-fields',
    '/reviews',
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/firebase',
  ];

  static const _noRefreshPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/logout',
    '/auth/firebase',
    '/telemetry/',
  ];
  static const _retriedKey = 'pm_retried_after_refresh';
  Completer<_RefreshOutcome>? _refreshing;

  int _inflight = 0;
  final List<Completer<void>> _waiters = [];
  static const _maxConcurrent = 4;

  DioConsumer({required this.client}) {
    client.interceptors.addAll([
      _connectivityInterceptor(),
      _authInterceptor(),
      if (kDebugMode) HttpFormatter(),
    ]);

    client.options
      ..baseUrl = EndPoints.baseUrl
      ..connectTimeout = const Duration(milliseconds: 30000)
      ..receiveTimeout = const Duration(milliseconds: 30000)
      ..responseType = ResponseType.plain
      ..followRedirects = false
      ..validateStatus = (status) {
        return status != null && status < 500 && status != 401 && status != 429;
      };
  }

  @override
  Future<Either<String, ApiModel>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _gated(
        () => client.get(path, queryParameters: queryParameters),
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (_) {
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    bool formDataIsEnabled = false,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _gated(
        () => client.post(
          path,
          queryParameters: queryParameters,
          data: body,
          options: headers != null ? Options(headers: headers) : null,
        ),
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (_) {
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
    } catch (_) {
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
      final response = await _gated(
        () => client.put(
          path,
          queryParameters: queryParameters,
          data: body,
        ),
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (_) {
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
      final response = await _gated(
        () => client.patch(
          path,
          queryParameters: queryParameters,
          data: body,
        ),
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (_) {
      return left('unexpected_error'.tr());
    }
  }

  @override
  Future<Either<String, ApiModel>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _gated(
        () => client.delete(path, queryParameters: queryParameters),
      );
      return handleResponseStatus(response);
    } on DioException catch (e) {
      return left(handleDioError(e).toString());
    } catch (_) {
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
        final serverMessage = _serverMessage(error.response);
        if (serverMessage != null && code != StatusCode.badRequest) {
          return FetchDataException(serverMessage);
        }
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

  /// The backend's `message` (string or list) from an error body, or null.
  String? _serverMessage(Response? response) {
    if (response == null || response.statusCode == 429) return null;
    try {
      final json = handleResponseAsJson(response);
      final m = json['message'];
      final text = m is List ? m.map((e) => e.toString()).join('\n') : m?.toString();
      return (text == null || text.trim().isEmpty) ? null : text;
    } catch (_) {
      return null;
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
        options.headers.addAll(EndPoints.clientHeaders());
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
          final options = e.requestOptions;
          final canRefresh = options.extra[AppString.requiresTokenKey] != false &&
              options.extra[_retriedKey] != true &&
              !_noRefreshPaths.any(options.path.contains);
          if (canRefresh) {
            final outcome = await _refreshAccessToken();
            final token = outcome.token;
            if (token != null) {
              try {
                options.extra[_retriedKey] = true;
                options.headers[AppString.headerAuthorization] = 'Bearer $token';
                return handler.resolve(await client.fetch(options));
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
            // Network or server trouble during refresh is not a sign-out.
            if (outcome.status == _RefreshStatus.unavailable) {
              return handler.next(e);
            }
          }
          await _handleUnauthorized(options.path);
        }
        final code = e.response?.statusCode ?? 0;
        if (code >= 500 && !e.requestOptions.path.contains('/telemetry/')) {
          unawaited(
            TelemetryReporter.report(
              kind: 'error',
              message: e.message ?? 'HTTP $code',
              stack: e.response?.data?.toString(),
            ),
          );
        }
        return handler.next(e);
      },
    );
  }

  /// Exchanges the stored refresh token (single flight). Only a refresh the
  /// server actively rejects ends the session; network or server failures
  /// report [_RefreshStatus.unavailable] so the user stays signed in.
  Future<_RefreshOutcome> _refreshAccessToken() async {
    final pending = _refreshing;
    if (pending != null) return pending.future;
    final completer = Completer<_RefreshOutcome>();
    _refreshing = completer;
    _RefreshOutcome finish(_RefreshOutcome outcome) {
      if (!completer.isCompleted) completer.complete(outcome);
      return outcome;
    }

    try {
      final storage = sl<HandleMultiCallLocal>();
      final refresh = await storage.getLocalData(keyType: LocalEnumKey.refreshToken);
      if (refresh == null || refresh.isEmpty) {
        return finish(const (status: _RefreshStatus.rejected, token: null));
      }
      // Bare client: no interceptors, so a failing refresh cannot recurse.
      final bare = Dio(
        BaseOptions(
          baseUrl: client.options.baseUrl,
          connectTimeout: client.options.connectTimeout,
          receiveTimeout: client.options.receiveTimeout,
          headers: EndPoints.clientHeaders(),
        ),
      );
      final res = await bare.post(EndPoints.refresh, data: {'refreshToken': refresh});
      final data = (res.data is Map ? res.data['data'] : null) as Map?;
      final access = data?['accessToken']?.toString();
      final nextRefresh = data?['refreshToken']?.toString();
      if (access == null || access.isEmpty) {
        return finish(const (status: _RefreshStatus.unavailable, token: null));
      }
      await storage.saveLocalData(data: access, keyType: LocalEnumKey.accessToken);
      if (nextRefresh != null && nextRefresh.isNotEmpty) {
        await storage.saveLocalData(data: nextRefresh, keyType: LocalEnumKey.refreshToken);
      }
      return finish((status: _RefreshStatus.renewed, token: access));
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      final rejected = code == 400 || code == 401 || code == 403;
      return finish((
        status: rejected ? _RefreshStatus.rejected : _RefreshStatus.unavailable,
        token: null,
      ));
    } catch (_) {
      return finish(const (status: _RefreshStatus.unavailable, token: null));
    } finally {
      _refreshing = null;
    }
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

  Future<Response<dynamic>> _gated(
    Future<Response<dynamic>> Function() send,
  ) async {
    if (_inflight >= _maxConcurrent) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }
    _inflight++;
    try {
      return await send();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        return await send();
      }
      rethrow;
    } finally {
      _inflight--;
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete();
      }
    }
  }
}

enum _RefreshStatus { renewed, rejected, unavailable }

typedef _RefreshOutcome = ({_RefreshStatus status, String? token});
