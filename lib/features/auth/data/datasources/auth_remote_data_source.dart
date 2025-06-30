import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Выполняет вход пользователя с использованием email и пароля.
  Future<UserModel> login({required String email, required String password});

  /// Выполняет регистрацию нового пользователя с использованием email, пароля и имени.
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });

  /// Выполняет выход пользователя из системы.
  /// Важно: реализация должна очищать кэш пользователя.
  Future<void> logout();

  /// Обновляет токен доступа пользователя с использованием refresh-токена.
  /// Важно: реализация должна обновлять кэш пользователя.
  Future<UserModel> refresh({required String refreshToken});

  /// Выполняет вход пользователя с использованием Google OAuth.
  /// Возвращает объект UserModel, если вход успешен, или null в случае ошибки
  Future<UserModel?> googleSignIn({required String accessToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.client});
  final DioClient client;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async => _handle<UserModel>(
    () async => client.post<UserModel>(
      '/api/auth/login/',
      data: {'email': email, 'password': password},
    ),
  );

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async => _handle<UserModel>(
    () async => client.post<UserModel>(
      '/api/auth/register/',
      data: {'email': email, 'password': password, 'name': name},
    ),
  );

  @override
  Future<UserModel> refresh({required String refreshToken}) async =>
      _handle<UserModel>(
        () async => client.post<UserModel>(
          '/api/auth/refresh/',
          data: {"refresh_token": refreshToken},
        ),
      );

  @override
  Future<void> logout() async {
    // Реализация выхода из системы
  }

  T _handle<T>(Future<T> Function() f) {
    try {
      return f.call() as T;
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Обработка исключений для конкретного контекста
  Exception _handleException(dynamic e) {
    if (e is AppException) {
      return e;
    }
    return ServerException('Auth service error: ${e.toString()}');
  }

  @override
  Future<UserModel?> googleSignIn({required String accessToken}) async =>
      _handle<UserModel>(
        () async => client.post<UserModel>(
          '/api/auth/google/',
          data: {'access_token': accessToken},
        ),
      );
}
