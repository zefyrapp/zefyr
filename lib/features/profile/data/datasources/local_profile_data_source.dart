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
}

class LocalProfileDataSourceImpl implements LocalProfileDataSource {
  // Простая реализация с Map для демонстрации
  final Map<String, ProfileModel> _profileCache = {};
  ProfileModel? _myProfile;

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    _profileCache[profile.user.id] = profile;
  }

  @override
  Future<ProfileModel?> getCachedProfile(String userId) async =>
      _profileCache[userId];

  @override
  Future<void> clearProfileCache(String userId) async {
    _profileCache.remove(userId);
  }

  @override
  Future<ProfileModel?> getMyCachedProfile() async => _myProfile;

  @override
  Future<void> cacheMyProfile(ProfileModel profile) async {
    _myProfile = profile;
  }
}
