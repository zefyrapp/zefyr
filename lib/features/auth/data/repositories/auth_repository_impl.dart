import 'package:dartz/dartz.dart';
import 'package:zifyr/core/error/exceptions.dart';
import 'package:zifyr/core/error/failures.dart';
import 'package:zifyr/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:zifyr/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zifyr/features/auth/domain/entities/user.dart';
import 'package:zifyr/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
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
  Future<Either<Failure, User>> register(
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
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException {
      return const Right(null);
    }
  }
}
