import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/domain/repositories/profile_repository.dart';

class GetMyProfile extends UseCase<ProfileEntity, NoParams>
    with UseCaseLogging<ProfileEntity, NoParams> {
  GetMyProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, ProfileEntity>> executeUseCase(
    NoParams params,
  ) async => repository.getMyProfile();
}
