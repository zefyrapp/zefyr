import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/repositories/edit_profile_repository.dart';

/// Использование сервиса отправки запроса на изменение профиля
class EditProfile extends UseCase<AuthResponse, EditProfileRequest>
    with UseCaseLogging<AuthResponse, EditProfileRequest> {
  /// Реализация сервиса отправки запроса на изменение профиля
  EditProfile(this.repository);
  final EditProfileRepository repository;

  @override
  Future<Either<Failure, AuthResponse>> executeUseCase(
    EditProfileRequest params,
  ) async => repository.edit(params);
}
