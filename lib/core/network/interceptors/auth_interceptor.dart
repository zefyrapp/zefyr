import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/features/auth/data/datasources/user_dao.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';

/// Интерцептор для управления токенами авторизации и автоматического их обновления.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.userDao,
    required this.dio,
    required this.ref,
  });

  final UserDao userDao;
  final Dio dio;
  final Ref ref;

  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('auth/refresh')) {
      return handler.next(options);
    }
    final tokens = await userDao.getTokensOnly();
    if (tokens?.accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${tokens!.accessToken}';
    }
    return handler.next(options);
  }

  /// Этот метод будет перехватывать успешные ответы.
  /// Если код ответа 401, мы не считаем его "успешным" и перенаправляем в onError.
  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.statusCode == 401) {
      log('Received 401 in onResponse. Rejecting to trigger onError logic.');
      // Отклоняем ответ, превращая его в ошибку DioException.
      // Это автоматически вызовет следующий в цепочке `onError`.
      return handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Unauthorized',
          type: DioExceptionType.badResponse,
        ),
      );
    }
    return handler.next(response);
  }

  /// Вся основная логика обновления токена сосредоточена здесь.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Обрабатываем только ошибки 401 (Unauthorized).
    // Сюда попадут как "настоящие" ошибки, так и ответы, отклоненные из onResponse.
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Избегаем бесконечного цикла, если сам запрос на обновление токена вернул 401.
    if (err.requestOptions.path.contains('auth/refresh')) {
      log('Refresh token is invalid or expired. Logging out.');
      await _handleLogout();
      return handler.next(err);
    }

    log('Caught 401 error. Attempting to refresh token...');

    try {
      // Получаем новый токен. Эта функция гарантирует, что refresh будет вызван только один раз.
      final newAccessToken = await _getRefreshedToken();

      // Повторяем изначальный запрос с новым токеном.
      final response = await _retryRequest(err.requestOptions, newAccessToken);

      // Завершаем обработку, возвращая успешный ответ.
      return handler.resolve(response);
    } catch (e) {
      log('Failed to refresh token or retry request: $e');
      // Если обновление не удалось, разлогиниваем пользователя и передаем ОРИГИНАЛЬНУЮ ошибку дальше.
      await _handleLogout();
      return handler.next(err);
    }
  }

  // --- Вспомогательные методы (остаются без изменений) ---

  Future<String> _getRefreshedToken() async {
    _refreshFuture ??= _performRefresh();
    try {
      final newToken = await _refreshFuture;
      if (newToken == null) {
        throw const AuthException(
          'Failed to refresh token: new token is null.',
        );
      }
      return newToken;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    final oldTokens = await userDao.getTokensOnly();
    final refreshToken = oldTokens?.refreshToken;
    if (refreshToken == null) {
      log('No refresh token available for renewal.');
      return null;
    }
    try {
      final refreshDio = Dio();
      final response = await refreshDio.post<Map<String, dynamic>>(
        'https://back.tanysu.net/api/auth/refresh/',
        data: {'refresh': refreshToken},
      );
      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromMap(response.data!);
        await userDao.updateTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );
        log('Token successfully refreshed.');
        return authResponse.accessToken;
      }
    } on DioException catch (e) {
      log('Error refreshing token API call: ${e.response?.data}');
    } catch (e) {
      log('An unexpected error occurred during token refresh: $e');
    }
    return null;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    log('Retrying request to: ${requestOptions.path}');
    final options = requestOptions.copyWith(
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
    );
    return dio.fetch(options);
  }

  Future<void> _handleLogout() async {
    await userDao.clearUser();
    // ref.read(authNotifierProvider.notifier).logout();
    log('User logged out due to authentication failure.');
  }
}
