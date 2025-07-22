import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/core/network/models/api_response.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResponse<void>> checkEmail({required String email});

  /// Выполняет вход пользователя с использованием email и пароля.
  Future<AuthResponse> login({required String email, required String password});

  /// Выполняет регистрацию нового пользователя с использованием email, пароля и имени.
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String dateOfBirth,
    String? name,
  });

  /// Выполняет выход пользователя из системы.
  /// Важно: реализация должна очищать кэш пользователя.
  Future<void> logout();

  /// Обновляет токен доступа пользователя с использованием refresh-токена.
  /// Важно: реализация должна обновлять кэш пользователя.
  Future<AuthResponse> refresh({required String refreshToken});

  /// Выполняет вход пользователя с использованием Google OAuth.
  /// Возвращает объект UserModel, если вход успешен, или null в случае ошибки
  Future<AuthResponse> googleSignIn({required String accessToken});

  Future<AuthResponse> appleSignIn({required String identityToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.client});
  final DioClient client;

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async => _handle<AuthResponse>(
    () async => (await client.postWithApiResponse<AuthResponse>(
      '/api/auth/login/',
      data: {'email': email, 'password': password},
      fromJson: AuthResponse.fromMap,
    )).data!,
  );

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String dateOfBirth,
    String? name,
  }) async => _handle<AuthResponse>(
    () async => (await client.postWithApiResponse<AuthResponse>(
      '/api/auth/register/',
      data: {
        'email': email,
        'password': password,
        'date_of_birth': dateOfBirth,
        'nickname': name,
      },
      fromJson: AuthResponse.fromMap,
    )).data!,
  );

  @override
  Future<AuthResponse> refresh({required String refreshToken}) async =>
      _handle<AuthResponse>(
        () async => client.post<AuthResponse>(
          '/api/auth/refresh/',
          data: {"refresh_token": refreshToken},
        ),
      );

  @override
  Future<void> logout() async {
    // Реализация выхода из системы
  }

  Future<T> _handle<T>(Future<T> Function() f) async {
    try {
      return f.call();
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
  Future<AuthResponse> googleSignIn({required String accessToken}) async =>
      _handle<AuthResponse>(
        () async => client.postWithApiResponse<AuthResponse>(
          '/api/auth/google/',
          data: {'access_token': accessToken},
        ),
      );
  @override
  Future<AuthResponse> appleSignIn({required String identityToken}) async =>
      _handle<AuthResponse>(
        () async => client.postWithApiResponse<AuthResponse>(
          '/api/auth/apple/',
          data: {'identity_token': identityToken},
        ),
      );

  @override
  Future<ApiResponse<void>> checkEmail({required String email}) async =>
      _handle<ApiResponse<void>>(
        () async => client.postWithApiResponse<ApiResponse<void>>(
          '/api/auth/check-email/',
          data: {'email': email},
          fromJson: ApiResponse<void>.fromJson,
        ),
      );
}
