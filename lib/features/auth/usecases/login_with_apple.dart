import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class LoginWithApple implements UseCase<AuthResponse, NoParams> {
  const LoginWithApple(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResponse>> call(NoParams params) =>
      repository.loginWithApple();
}
