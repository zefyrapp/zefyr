import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/auth/domain/entities/user.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser implements UseCase<AuthResponse, RegisterParams> {
  const RegisterUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParams params) async =>
      repository.register(
        params.email,
        params.password,
        params.dateOfBirth,
        params.name,
      );
}

class RegisterParams {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.dateOfBirth,
    this.name,
  });
  final String email;
  final String password;
  final String dateOfBirth;
  final String? name;
}
