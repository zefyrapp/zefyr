import 'package:dartz/dartz.dart';
import 'package:zifyr/core/error/failures.dart';
import 'package:zifyr/core/usecases/usecases.dart';
import 'package:zifyr/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  const LogoutUser(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async =>
      repository.logout();
}
