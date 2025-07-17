import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class LoginUser implements UseCase<AuthResponse, LoginParams> {
  const LoginUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResponse>> call(LoginParams params) async =>
      repository.login(params.email, params.password);
}

class LoginParams {
  const LoginParams({required this.email, required this.password});
  final String email;
  final String password;
}
