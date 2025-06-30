import 'package:dartz/dartz.dart';
import 'package:zifyr/core/error/failures.dart';
import 'package:zifyr/core/usecases/usecases.dart';
import 'package:zifyr/features/auth/domain/entities/user.dart';
import 'package:zifyr/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<UserEntity, LoginParams> {
  const LoginUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async =>
      repository.login(params.email, params.password);
}

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}
