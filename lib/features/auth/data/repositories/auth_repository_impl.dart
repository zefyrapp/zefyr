import 'package:dartz/dartz.dart';
import 'package:zefyr/common/exceptions/repository_helper.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/network/models/api_response.dart';
import 'package:zefyr/features/auth/data/datasources/apple_signIn_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/google_signIn_data_source.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.googleSignInDataSource,
    required this.appleSignInDataSource,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GoogleSignInDataSource googleSignInDataSource;
  final AppleSignInDataSource appleSignInDataSource;
  @override
  Future<Either<Failure, AuthResponse>> login(
    String email,
    String password,
  ) async => RepositoryHelper.safeCallWithCallback(
    () async => remoteDataSource.login(email: email, password: password),
    localDataSource.cacheUser,
  );

  @override
  Future<Either<Failure, AuthResponse>> register(
    String email,
    String password,
    String dateOfBirth,
    String? name,
  ) async => RepositoryHelper.safeCallWithCallback(
    () async => remoteDataSource.register(
      email: email,
      password: password,
      dateOfBirth: dateOfBirth,
      name: name,
    ),
    localDataSource.cacheUser,
  );

  @override
  Future<Either<Failure, void>> logout() async =>
      RepositoryHelper.safeCallWithCallback(
        remoteDataSource.logout,
        (_) => localDataSource.clearCache(),
      );

  @override
  Future<Either<Failure, AuthResponse?>> getCurrentUser() async =>
      RepositoryHelper.safeCall(localDataSource.getCachedUser);

  @override
  Future<Either<Failure, AuthResponse>> loginWithGoogle() async =>
      RepositoryHelper.safeCall(() async {
        final client = await googleSignInDataSource.signIn();
        if (client == null) {
          throw const AuthException('Google sign-in cancelled');
        }

        final idToken = client.authentication.idToken;
        if (idToken == null) {
          throw const AuthException('Failed to get ID token');
        }

        final user = await remoteDataSource.googleSignIn(accessToken: idToken);
        await localDataSource.cacheUser(user);
        return user;
      });
  @override
  Future<Either<Failure, AuthResponse>> loginWithApple() async =>
      RepositoryHelper.safeCall(() async {
        final credential = await appleSignInDataSource.signIn();
        if (credential == null) {
          throw const AuthException('Apple sign-in cancelled');
        }

        final identityToken = credential.identityToken;
        if (identityToken == null) {
          throw const AuthException('Failed to get identity token from Apple');
        }

        // Передаем identity token и дополнительную информацию на бэкенд
        final user = await remoteDataSource.appleSignIn(
          identityToken: identityToken,
        );

        await localDataSource.cacheUser(user);
        return user;
      });
  @override
  Future<Either<Failure, bool>> isAppleSignInAvailable() async =>
      RepositoryHelper.safeCall(
        () async => appleSignInDataSource.isAvailable(),
      );
  @override
  Future<Either<Failure, ApiResponse<dynamic>>> checkEmail({
    required String email,
  }) async => RepositoryHelper.safeCall(
    () async => remoteDataSource.checkEmail(email: email),
  );

  @override
  Future<Either<Failure, AuthResponse>> refresh(String refreshToken) async =>
      RepositoryHelper.safeCallWithCallback(
        () async => remoteDataSource.refresh(refreshToken: refreshToken),
        localDataSource.updateTokens,
      );
}
