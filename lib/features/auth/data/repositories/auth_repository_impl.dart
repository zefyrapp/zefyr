import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zefyr/features/auth/data/datasources/google_signIn_data_source.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.googleSignInDataSource,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GoogleSignInDataSource googleSignInDataSource;
  @override
  Future<Either<Failure, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final client = await googleSignInDataSource.signIn();
      if (client == null) {
        return const Left(AuthFailure(message: 'Google sign-in cancelled'));
      }
      // Получите email пользователя через id_token или userinfo endpoint
      // Здесь пример получения id_token:
      final idToken = client.authentication.idToken;
      // TODO: отправьте idToken на ваш backend для верификации и получения UserEntity
      // Пример:
      // final user = await remoteDataSource.loginWithGoogle(idToken);
      // await localDataSource.cacheUser(user);
      // return Right(user);
      return const Left(
        AuthFailure(
          message:
              'Google sign-in flow не завершён (добавьте backend обработку)',
        ),
      );
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmail({required String email}) async {
    try {
      return Right(await remoteDataSource.checkEmail(email: email));
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
