import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/domain/repositories/auth_repository.dart';

class CheckEmail implements UseCase<void, CheckEmailParams> {
  const CheckEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(CheckEmailParams params) async =>
      repository.checkEmail(email: params.email);
}

class CheckEmailParams {
  const CheckEmailParams({required this.email});
  final String email;
}
