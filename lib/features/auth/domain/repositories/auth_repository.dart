import 'package:dartz/dartz.dart';
import 'package:zifyr/core/error/failures.dart';
import 'package:zifyr/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String name,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
