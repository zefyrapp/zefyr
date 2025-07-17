import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/domain/repositories/profile_repository.dart';

class UpdateMyProfile extends UseCase<ProfileEntity, EditProfileRequest>
    with UseCaseLogging<ProfileEntity, EditProfileRequest> {
  UpdateMyProfile(this.repository);

  final ProfileRepository repository;

  @override
  Future<Either<Failure, ProfileEntity>> executeUseCase(
    EditProfileRequest params,
  ) async => repository.updateMyProfile(params);
}
