import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/core/network/models/api_response.dart';
import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';

/// Интерцептор для авторизации
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.userDao, required this.ref});

  final UserDao userDao;
  final Ref ref;

  // Флаг для отслеживания обработки токена
  bool _isRefreshing = false;
  final List<VoidCallback> _failedQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Добавить логику получения токена из AuthRepository или SecureStorage
    // final token = getAuthToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // Если не 401, просто продолжаем
    if (response.statusCode != 401) {
      return handler.next(response);
    }

    // Обрабатываем 401 ошибку
    bool handlerCalled = false;

    await _handle401Error(
      requestOptions: response.requestOptions,
      onSuccess: (newToken) async {
        if (handlerCalled) return;
        handlerCalled = true;

        // Повторяем запрос с новым токеном
        final dio = Dio();
        response.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final retryResponse = await dio.fetch<Response<dynamic>>(
            response.requestOptions,
          );
          handler.resolve(retryResponse);
        } catch (e) {
          handler.next(response);
        }
      },
      onFailure: () {
        if (handlerCalled) return;
        handlerCalled = true;

        // Если не удалось обновить токен, возвращаем оригинальный ответ
        handler.next(response);
      },
    );
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    log('Error AuthInterceptor: ${err.message}');

    // Если не 401, просто продолжаем
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Обрабатываем 401 ошибку
    bool handlerCalled = false;

    await _handle401Error(
      requestOptions: err.requestOptions,
      onSuccess: (newToken) async {
        if (handlerCalled) return;
        handlerCalled = true;

        // Повторяем запрос с новым токеном
        final dio = Dio();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        try {
          final retryResponse = await dio.fetch<Response<dynamic>>(
            err.requestOptions,
          );
          handler.resolve(retryResponse);
        } catch (e) {
          handler.next(err);
        }
      },
      onFailure: () {
        if (handlerCalled) return;
        handlerCalled = true;

        // Если не удалось обновить токен, возвращаем оригинальную ошибку
        handler.next(err);
      },
    );
  }

  /// Общая логика обработки 401 ошибки
  Future<void> _handle401Error({
    required RequestOptions requestOptions,
    required ValueChanged<String> onSuccess,
    required VoidCallback onFailure,
  }) async {
    // Если уже идет процесс обновления токена, добавляем в очередь
    if (_isRefreshing) {
      _failedQueue.add(() async {
        final auth = await userDao.getTokensOnly();
        if (auth?.accessToken != null) {
          onSuccess(auth!.accessToken);
        } else {
          onFailure();
        }
      });
      return;
    }

    _isRefreshing = true;

    try {
      final auth = await userDao.getTokensOnly();

      if (auth == null) {
        // Нет токенов, выходим из системы
        //?TODO: реализация выхода из системы
        onFailure();
        return;
      }

      final newAccessToken = await _refreshToken(auth.refreshToken);

      if (newAccessToken != null) {
        onSuccess(newAccessToken);
        // Обрабатываем очередь ожидающих запросов
        _processFailedQueue(newAccessToken);
      } else {
        // Не удалось обновить токен, выходим из системы
        //?TODO: реализация выхода из системы
        onFailure();
        _processFailedQueue(null);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Обрабатывает очередь отложенных запросов
  void _processFailedQueue(String? token) {
    for (final callback in _failedQueue) {
      callback();
    }
    _failedQueue.clear();
  }

  /// Обновляет токен с использованием refresh token
  Future<String?> _refreshToken(String refreshToken) async {
    try {
      // Создаем новый Dio instance для refresh запроса
      // чтобы избежать циклических вызовов интерцептора
      final dio = Dio();

      final response = await dio.post<Map<String, dynamic>>(
        'https://back.tanysu.net/api/auth/refresh/',
        data: {'refresh_token': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = ApiResponse.fromJson(
          response.data!,
          fromJsonT: AuthResponse.fromMap,
        );

        // Сохраняем новые токены в базе данных
        await userDao.updateTokens(
          accessToken: authResponse.data!.accessToken,
          refreshToken: authResponse.data!.refreshToken,
        );

        return authResponse.data!.accessToken;
      }
    } catch (e) {
      log('Error refreshing token: $e');
    }

    return null;
  }
}
