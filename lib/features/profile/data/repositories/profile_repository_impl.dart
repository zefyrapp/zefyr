import 'package:dartz/dartz.dart';
import 'package:zefyr/common/exceptions/repository_helper.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/features/profile/data/datasources/local_profile_data_source.dart';
import 'package:zefyr/features/profile/data/datasources/remote_profile_data_source.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final RemoteProfileDataSource remoteDataSource;
  final LocalProfileDataSource localDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getMyProfile() =>
      RepositoryHelper.safeCall(() async {
        try {
          // Сначала пытаемся получить из кеша
          final cachedProfile = await localDataSource.getMyCachedProfile();
          if (cachedProfile != null) {
            // Возвращаем кеш, но в фоне обновляем
            _updateCacheInBackground();
            return cachedProfile;
          }

          // Если кеша нет, делаем запрос
          final response = await remoteDataSource.getMyProfile();
          await localDataSource.cacheMyProfile(response);
          return response;
        } catch (e) {
          // Если сеть недоступна, возвращаем кеш
          final cachedProfile = await localDataSource.getMyCachedProfile();
          if (cachedProfile != null) {
            return cachedProfile;
          }
          rethrow;
        }
      });

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) =>
      RepositoryHelper.safeCall(() async {
        try {
          // Сначала пытаемся получить из кеша
          final cachedProfile = await localDataSource.getCachedProfile(userId);
          if (cachedProfile != null) {
            // Возвращаем кеш, но в фоне обновляем
            _updateUserCacheInBackground(userId);
            return cachedProfile;
          }

          // Если кеша нет, делаем запрос
          final response = await remoteDataSource.getUserProfile(userId);
          await localDataSource.cacheProfile(response);
          return response;
        } catch (e) {
          // Если сеть недоступна, возвращаем кеш
          final cachedProfile = await localDataSource.getCachedProfile(userId);
          if (cachedProfile != null) {
            return cachedProfile;
          }
          rethrow;
        }
      });

  @override
  Future<Either<Failure, ProfileEntity>> updateMyProfile(
    EditProfileRequest request,
  ) => RepositoryHelper.safeCall(() async {
    final response = await remoteDataSource.updateMyProfile(request);
    // Обновляем кеш после успешного обновления
    await localDataSource.cacheMyProfile(response);
    return response;
  });

  // Вспомогательные методы для обновления кеша в фоне
  void _updateCacheInBackground() {
    remoteDataSource
        .getMyProfile()
        .then((response) {
          localDataSource.cacheMyProfile(response);
        })
        .catchError((_) {
          // Игнорируем ошибки фонового обновления
        });
  }

  void _updateUserCacheInBackground(String userId) {
    remoteDataSource
        .getUserProfile(userId)
        .then((response) {
          localDataSource.cacheProfile(response);
        })
        .catchError((_) {
          // Игнорируем ошибки фонового обновления
        });
  }
}
