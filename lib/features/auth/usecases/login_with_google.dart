import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class LoginWithGoogle implements UseCase<UserEntity, NoParams> {
  const LoginWithGoogle(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) =>
      repository.loginWithGoogle();
}
