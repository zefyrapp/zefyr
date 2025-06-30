import 'package:zifyr/core/error/exceptions.dart';
import 'package:zifyr/core/network/dio_client.dart';
import 'package:zifyr/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<UserModel> refresh({required String refreshToken});
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
}
