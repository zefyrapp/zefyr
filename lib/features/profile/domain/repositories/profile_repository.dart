import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';

/// Интерфейс репозитория для работы с профилем
abstract class ProfileRepository {
  /// Получить свой профиль
  Future<Either<Failure, ProfileEntity>> getMyProfile();

  /// Получить профиль другого пользователя
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId);

  /// Обновить свой профиль
  Future<Either<Failure, ProfileEntity>> updateMyProfile(
    EditProfileRequest request,
  );
}
