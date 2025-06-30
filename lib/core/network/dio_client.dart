import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zifyr/core/error/exceptions.dart';
import 'package:zifyr/core/network/interceptors/auth_interceptor.dart';
import 'package:zifyr/core/network/interceptors/logging_interceptor.dart';
import 'package:zifyr/core/network/interceptors/network_interceptor.dart';
import 'package:zifyr/core/network/interceptors/retry_interceptor.dart';
import 'package:zifyr/core/network/network_info.dart';
import 'package:zifyr/core/network/parsers/response_parser.dart';

part 'dio_client.g.dart';

/// Провайдер для DioClient
@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) =>
    DioClient(networkInfo: ref.watch(networkInfoProvider));

/// Провайдер для NetworkInfo
@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) => NetworkInfoImpl(Connectivity());

/// Основной HTTP клиент на базе Dio
class DioClient {
  DioClient({
    required NetworkInfo networkInfo,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) : _networkInfo = networkInfo {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            baseUrl ?? 'https://back.tanysu.net', // Замените на ваш базовый URL
        connectTimeout: connectTimeout ?? const Duration(seconds: 30),
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
        sendTimeout: sendTimeout ?? const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final NetworkInfo _networkInfo;
  final ResponseParser _parser = ResponseParser();

  /// Настройка интерцепторов
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      NetworkInterceptor(_networkInfo),
      AuthInterceptor(),
      RetryInterceptor(),
      if (kDebugMode) LoggingInterceptor(),
    ]);
  }

  /// GET запрос с универсальным парсингом
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST запрос с универсальным парсингом
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT запрос с универсальным парсингом
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH запрос с универсальным парсингом
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE запрос с универсальным парсингом
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Загрузка файла
  Future<T> upload<T>(
    String path, {
    required FormData formData,
    Options? options,
    T Function(Map<String, dynamic>)? fromJson,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return await _parseResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Скачивание файла
  Future<void> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Универсальный парсинг ответа через compute
  Future<T> _parseResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw _createHttpException(response);
    }

    return _parser.parseResponse<T>(response, fromJson: fromJson);
  }

  /// Обработка ошибок
  AppException _handleError(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    if (error is SocketException) {
      return const NetworkException('Нет подключения к интернету');
    }

    if (error is FormatException) {
      return FormatException('Ошибка формата данных: ${error.message}');
    }

    return ServerException('Неизвестная ошибка: ${error.toString()}');
  }

  /// Обработка DioException
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException('Превышено время ожидания');

      case DioExceptionType.badResponse:
        return _createHttpException(error.response);

      case DioExceptionType.cancel:
        return const ServerException('Запрос был отменен');

      case DioExceptionType.connectionError:
        return const NetworkException('Ошибка соединения');

      case DioExceptionType.badCertificate:
        return const ServerException('Ошибка SSL сертификата');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException('Нет подключения к интернету');
        }
        return ServerException('Неизвестная ошибка: ${error.message}');
    }
  }

  /// Создание HTTP исключения на основе статуса
  AppException _createHttpException(Response<dynamic>? response) {
    if (response == null) {
      return const ServerException('Пустой ответ от сервера');
    }

    final statusCode = response.statusCode ?? 0;
    final message = _extractErrorMessage(response);

    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return AuthException(message);
      case 403:
        return PermissionException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 429:
        return LimitExceededException(message);
      case 503:
        return ServiceUnavailableException(message);
      default:
        if (statusCode >= 500) {
          return ServerException(message);
        }
        return ServerException('HTTP Error $statusCode: $message');
    }
  }

  /// Извлечение сообщения об ошибке из ответа
  String _extractErrorMessage(Response<dynamic> response) {
    try {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String? ??
            'Ошибка HTTP ${response.statusCode}';
      }
      return data?.toString() ?? 'Ошибка HTTP ${response.statusCode}';
    } catch (e) {
      return 'Ошибка HTTP ${response.statusCode}';
    }
  }

  /// Получение базового URL
  String get baseUrl => _dio.options.baseUrl;

  /// Установка базового URL
  set baseUrl(String url) => _dio.options.baseUrl = url;

  /// Получение заголовков по умолчанию
  Map<String, dynamic> get defaultHeaders => _dio.options.headers;

  /// Установка заголовка
  void setHeader(String key, dynamic value) {
    _dio.options.headers[key] = value;
  }

  /// Удаление заголовка
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Очистка всех заголовков
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Установка токена авторизации
  void setAuthToken(String token) {
    setHeader('Authorization', 'Bearer $token');
  }

  /// Удаление токена авторизации
  void clearAuthToken() {
    removeHeader('Authorization');
  }

  /// Закрытие клиента
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

// Расширение для копирования RequestOptions
extension RequestOptionsExtension on RequestOptions {
  RequestOptions copyWith({
    String? method,
    String? baseUrl,
    String? path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    ResponseType? responseType,
    String? contentType,
    ValidateStatus? validateStatus,
    bool? receiveDataWhenStatusError,
    bool? followRedirects,
    int? maxRedirects,
    RequestEncoder? requestEncoder,
    ResponseDecoder? responseDecoder,
    bool? listFormat,
  }) => RequestOptions(
    method: method ?? this.method,
    baseUrl: baseUrl ?? this.baseUrl,
    path: path ?? this.path,
    queryParameters: queryParameters ?? this.queryParameters,
    extra: extra ?? this.extra,
    headers: headers ?? this.headers,
    responseType: responseType ?? this.responseType,
    contentType: contentType ?? this.contentType,
    validateStatus: validateStatus ?? this.validateStatus,
    receiveDataWhenStatusError:
        receiveDataWhenStatusError ?? this.receiveDataWhenStatusError,
    followRedirects: followRedirects ?? this.followRedirects,
    maxRedirects: maxRedirects ?? this.maxRedirects,
    requestEncoder: requestEncoder ?? this.requestEncoder,
    responseDecoder: responseDecoder ?? this.responseDecoder,
  );

  Future<Response<T>> request<T>() async {
    final dio = Dio();
    return dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: Options(
        method: method,
        sendTimeout: sendTimeout,
        receiveTimeout: receiveTimeout,
        extra: extra,
        headers: headers,
        responseType: responseType,
        contentType: contentType,
        validateStatus: validateStatus,
        receiveDataWhenStatusError: receiveDataWhenStatusError,
        followRedirects: followRedirects,
        maxRedirects: maxRedirects,
        requestEncoder: requestEncoder,
        responseDecoder: responseDecoder,
        listFormat: listFormat,
      ),
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
