import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileParams {
  const GetUserProfileParams({required this.nickname});

  final String nickname;
}

class GetUserProfile extends UseCase<ProfileEntity, GetUserProfileParams>
    with UseCaseLogging<ProfileEntity, GetUserProfileParams> {
  GetUserProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, ProfileEntity>> executeUseCase(
    GetUserProfileParams params,
  ) async => repository.getUserProfile(params.nickname);
}
