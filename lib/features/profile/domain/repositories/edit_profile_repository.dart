import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';

/// Интерфейс для реализации сервиса отправки запроса на изменение профиля
abstract class EditProfileRepository {
  /// Отправка запроса на изменение профиля
  Future<Either<Failure, AuthResponse>> edit(EditProfileRequest request);
}
