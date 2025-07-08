import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/network/exceptions.dart';
import 'package:zefyr/core/network/interceptors/auth_interceptor.dart';
import 'package:zefyr/core/network/interceptors/logging_interceptor.dart';
import 'package:zefyr/core/network/interceptors/network_interceptor.dart';
import 'package:zefyr/core/network/interceptors/retry_interceptor.dart';
import 'package:zefyr/core/network/models/api_response.dart';
import 'package:zefyr/core/network/network_info.dart';
import 'package:zefyr/core/network/parsers/response_parser.dart';
import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';

part 'dio_client.g.dart';

/// Провайдер для DioClient
@Riverpod(keepAlive: true)
DioClient dioClient(Ref ref) => DioClient(
  networkInfo: ref.watch(networkInfoProvider),
  userDao: ref.watch(userDaoProvider),
  ref: ref,
);

/// Провайдер для NetworkInfo
@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) => NetworkInfoImpl(Connectivity());

/// Основной HTTP клиент на базе Dio
class DioClient {
  DioClient({
    required NetworkInfo networkInfo,
    required UserDao userDao,
    required Ref ref,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) : _networkInfo = networkInfo,
       _userDao = userDao,
       _ref = ref {
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
        // validateStatus: (status) =>
        //     status != 401 || status != null && status < 500,
      ),
    );

    _setupInterceptors();
  }

  late final Dio _dio;
  final NetworkInfo _networkInfo;
  final UserDao _userDao;
  final Ref _ref;
  final ResponseParser _parser = ResponseParser();

  /// Настройка интерцепторов
  void _setupInterceptors() {
    _dio.interceptors.addAll([
      AuthInterceptor(userDao: _userDao, ref: _ref, dio: _dio),
      NetworkInterceptor(_networkInfo),

      RetryInterceptor(_dio),
      if (kDebugMode) LoggingInterceptor(),
    ]);
  }

  // --- МЕТОДЫ С ApiResponse ОБЕРТКОЙ ---

  /// GET запрос с ApiResponse оберткой
  Future<ApiResponse<T>> getWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST запрос с ApiResponse оберткой
  Future<ApiResponse<T>> postWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT запрос с ApiResponse оберткой
  Future<ApiResponse<T>> putWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH запрос с ApiResponse оберткой
  Future<ApiResponse<T>> patchWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE запрос с ApiResponse оберткой
  Future<ApiResponse<T>> deleteWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- МЕТОДЫ ДЛЯ СПИСКОВ С ApiListResponse ---

  /// GET запрос для получения списка с ApiListResponse оберткой
  Future<ApiListResponse<T>> getListWithApiResponse<T>(
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

      return await _parseApiListResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // --- КЛАССИЧЕСКИЕ МЕТОДЫ (БЕЗ ApiResponse ОБЕРТКИ) ---

  /// Классический GET запрос без ApiResponse обертки
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

  /// Классический POST запрос без ApiResponse обертки
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

  /// Классический PUT запрос без ApiResponse обертки
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

  /// Классический PATCH запрос без ApiResponse обертки
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

  /// Классический DELETE запрос без ApiResponse обертки
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

  // --- МЕТОДЫ ЗАГРУЗКИ И СКАЧИВАНИЯ ---

  /// Загрузка файла с ApiResponse оберткой
  Future<ApiResponse<T>> uploadWithApiResponse<T>(
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

      return await _parseApiResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Классическая загрузка файла
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

  /// Скачивание файла (остается без изменений)
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

  Future<ApiResponse<T>> _parseApiResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    // Проверяем статус код
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw _createHttpException(response);
    }

    // Парсим через ResponseParser
    // Указываем, что нужно использовать ApiResponse обертку
    final result = await _parser.parseResponse<ApiResponse<T>>(
      response,
      fromJson: fromJson != null
          ? (Map<String, dynamic> json) =>
                ApiResponse<T>.fromJson(json, fromJsonT: fromJson)
          : null,
    );

    // Проверяем success в ApiResponse
    if (!result.isSuccess) {
      throw ApiResponseException(result.message, errors: result.errors);
    }

    return result;
  }

  Future<ApiListResponse<T>> _parseApiListResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    // Проверяем статус код
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw _createHttpException(response);
    }

    // Парсим через ResponseParser
    // Указываем, что нужно использовать ApiResponse обертку
    final result = await _parser.parseResponse<ApiListResponse<T>>(
      response,
      fromJson: fromJson != null
          ? (Map<String, dynamic> json) =>
                ApiListResponse<T>.fromJson(json, fromJsonT: fromJson)
          : null,
    );

    // Проверяем success в ApiListResponse
    if (!result.isSuccess) {
      throw ApiResponseException(result.message, errors: result.errors);
    }

    return result;
  }

  /// Универсальный парсинг ответа через compute
  Future<T> _parseResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? fromJson, {
    bool useApiWrapper = false,
  }) async {
    if (response.statusCode != null && response.statusCode! >= 400) {
      throw _createHttpException(response);
    }

    return _parser.parseResponse<T>(
      response,
      fromJson: fromJson,
      useApiResponseWrapper: useApiWrapper,
    );
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

    // if (error is FormatException) {
    //   return FormatException('Ошибка формата данных: ${error.message}');
    // }

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
        if (data['errors'] != null) {
          final resp = ApiResponse<dynamic>.fromJson(data);
          return resp.firstValidationError ?? resp.message;
        } else {
          return data['message'] as String? ??
              data['msg'] as String? ??
              'Ошибка HTTP ${response.statusCode}';
        }
      }
      return data.toString();
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

  Future<Response<T>> request<T>(Dio dio) async => dio.request<T>(
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
