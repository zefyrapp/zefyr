import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/core/utils/handler/handler.dart';
import 'package:zefyr/features/auth/data/models/auth_response.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';

/// Интерфейс для реализации сервиса отправки запроса на изменение профиля
abstract class RemoteEditProfileDataSource {
  /// Отправка запроса на изменение профиля
  Future<AuthResponse> editProfile(EditProfileRequest request);
}

class RemoteEditProfileDataSourceImpl implements RemoteEditProfileDataSource {
  /// Реализация сервиса отправки запроса на изменение профиля
  const RemoteEditProfileDataSourceImpl(this.client);
  final DioClient client;

  @override
  Future<AuthResponse> editProfile(EditProfileRequest request) async =>
      Handler.handle<AuthResponse>(
        () async => (await client.patchWithApiResponse<AuthResponse>(
          '/api/profiles/my-profile/',
          data: request.toMap(),
          fromJson: AuthResponse.fromMap,
        )).data!,
      );
}
