import 'package:zefyr/features/profile/data/datasources/profile_dao.dart';
import 'package:zefyr/features/profile/data/models/profile_model.dart';

/// Интерфейс для локального хранения профиля
abstract class LocalProfileDataSource {
  /// Кеш профиля пользователя
  Future<void> cacheProfile(ProfileModel profile);

  /// Получить закешированный профиль
  Future<ProfileModel?> getCachedProfile(String userId);

  /// Очистить кеш профиля
  Future<void> clearProfileCache(String userId);

  /// Получить свой закешированный профиль
  Future<ProfileModel?> getMyCachedProfile();

  /// Кеш своего профиля
  Future<void> cacheMyProfile(ProfileModel profile);

  /// Очистить все профили
  Future<void> clearAllProfiles();
}

class LocalProfileDataSourceImpl implements LocalProfileDataSource {
  const LocalProfileDataSourceImpl(this.profileDao);

  final ProfileDao profileDao;

  @override
  Future<void> cacheProfile(ProfileModel profile) async =>
      profileDao.insertOrUpdateProfile(profile);

  @override
  Future<ProfileModel?> getCachedProfile(String userId) async =>
      profileDao.getProfile(userId);

  @override
  Future<void> clearProfileCache(String userId) async =>
      profileDao.deleteProfile(userId);

  @override
  Future<ProfileModel?> getMyCachedProfile() async => profileDao.getMyProfile();

  @override
  Future<void> cacheMyProfile(ProfileModel profile) async =>
      profileDao.insertOrUpdateMyProfile(profile);

  @override
  Future<void> clearAllProfiles() async => profileDao.clearAllProfiles();
}
