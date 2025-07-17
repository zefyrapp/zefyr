import 'package:dartz/dartz.dart';
import 'package:zefyr/common/exceptions/repository_helper.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/profile/data/datasources/remote_edit_profile_data_source.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/repositories/edit_profile_repository.dart';

class EditProfileRepositoryImpl implements EditProfileRepository {
  /// Реализация сервиса отправки запроса на изменение профиля
  const EditProfileRepositoryImpl(this.remoteDataSource);
  final RemoteEditProfileDataSource remoteDataSource;

  @override
  Future<Either<Failure, AuthResponse>> edit(EditProfileRequest request) =>
      RepositoryHelper.safeCall(
        () async => remoteDataSource.editProfile(request),
      );
}
