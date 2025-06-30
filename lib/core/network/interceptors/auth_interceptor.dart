import 'package:dio/dio.dart';

/// Интерцептор для авторизации
class AuthInterceptor extends Interceptor {
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Добавить логику обновления токена или редиректа на авторизацию
      // refreshToken() или logout()
    }
    handler.next(err);
  }
}
