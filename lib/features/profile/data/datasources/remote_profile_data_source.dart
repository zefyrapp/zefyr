import 'package:dio/dio.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/core/utils/handler/handler.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/data/models/profile_model.dart';

/// Интерфейс для работы с профилем пользователя
abstract class RemoteProfileDataSource {
  /// Получить свой профиль
  Future<ProfileModel> getMyProfile();

  /// Получить профиль другого пользователя
  Future<ProfileModel> getUserProfile(String userId);

  /// Обновить свой профиль
  Future<ProfileModel> updateMyProfile(EditProfileRequest request);
}

class RemoteProfileDataSourceImpl implements RemoteProfileDataSource {
  /// Реализация сервиса отправки запроса на изменение профиля
  const RemoteProfileDataSourceImpl(this.client);
  final DioClient client;

  @override
  Future<ProfileModel> getMyProfile() async =>
      Handler.handle<ProfileModel>(() async {
        final response = await client.getWithApiResponse<ProfileModel>(
          '/api/profiles/my-profile',
          fromJson: ProfileModel.fromMap,
        );
        return response.data!;
      });

  @override
  Future<ProfileModel> getUserProfile(String nickname) async =>
      Handler.handle<ProfileModel>(() async {
        final response = await client.getWithApiResponse<ProfileModel>(
          '/api/profiles/profile/$nickname',
          fromJson: ProfileModel.fromMap,
        );
        return response.data!;
      });

  @override
  Future<ProfileModel> updateMyProfile(EditProfileRequest request) async =>
      Handler.handle<ProfileModel>(() async {
        final response = await client.uploadPatchWithApiResponse<ProfileModel>(
          '/api/profiles/my-profile/',
          formData: FormData.fromMap(request.toMap()),
          fromJson: ProfileModel.fromMap,
        );
        return response.data!;
      });
}
