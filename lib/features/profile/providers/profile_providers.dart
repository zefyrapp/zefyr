import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/database/database.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/profile/data/datasources/local_profile_data_source.dart';
import 'package:zefyr/features/profile/data/datasources/profile_dao.dart';
import 'package:zefyr/features/profile/data/datasources/remote_profile_data_source.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/domain/repositories/profile_repository.dart';
import 'package:zefyr/features/profile/usecases/get_my_profile.dart';
import 'package:zefyr/features/profile/usecases/get_user_profile.dart';
import 'package:zefyr/features/profile/usecases/update_my_profile.dart';

part 'profile_providers.g.dart';

@riverpod
ProfileDao profileDao(Ref ref) => ProfileDao(ref.watch(appDatabaseProvider));
// Data Sources
@riverpod
RemoteProfileDataSource remoteProfileDataSource(Ref ref) =>
    RemoteProfileDataSourceImpl(ref.watch(dioClientProvider));

@riverpod
LocalProfileDataSource localProfileDataSource(Ref ref) =>
    LocalProfileDataSourceImpl(ref.watch(profileDaoProvider));

// Repository
@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepositoryImpl(
  remoteDataSource: ref.watch(remoteProfileDataSourceProvider),
  localDataSource: ref.watch(localProfileDataSourceProvider),
);

// Use Cases
@riverpod
GetMyProfile getMyProfile(Ref ref) =>
    GetMyProfile(ref.watch(profileRepositoryProvider));

@riverpod
GetUserProfile getUserProfile(Ref ref) =>
    GetUserProfile(ref.watch(profileRepositoryProvider));

@riverpod
UpdateMyProfile updateMyProfile(Ref ref) =>
    UpdateMyProfile(ref.watch(profileRepositoryProvider));

// Profile States
@Riverpod(keepAlive: true)
class MyProfileNotifier extends _$MyProfileNotifier {
  @override
  FutureOr<ProfileEntity?> build() async {
    final useCase = ref.watch(getMyProfileProvider);
    final result = await useCase(NoParams());

    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getMyProfileProvider);
      final result = await useCase(NoParams());

      return result.fold((failure) => throw failure, (profile) => profile);
    });
  }

  Future<void> updateProfile({
    required String name,
    required String nickname,
    required String bio,
    String? avatar,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(updateMyProfileProvider);
      late EditProfileRequest request;
      request = EditProfileRequest(name: name, nickname: nickname, bio: bio);
      if (avatar != null) {
        request = request.copyWith(avatar: File(avatar));
      }
      final result = await useCase(request);

      return result.fold((failure) => throw failure, (profile) => profile);
    });
  }
}

@Riverpod(keepAlive: true)
class UserProfileNotifier extends _$UserProfileNotifier {
  @override
  FutureOr<ProfileEntity?> build(String nickname) async {
    final useCase = ref.watch(getUserProfileProvider);
    final result = await useCase(GetUserProfileParams(nickname: nickname));

    return result.fold((failure) => throw failure, (profile) => profile);
  }

  Future<void> refresh(String nickname) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getUserProfileProvider);
      final result = await useCase(GetUserProfileParams(nickname: nickname));

      return result.fold((failure) => throw failure, (profile) => profile);
    });
  }
}

// Convenience providers
@riverpod
Future<ProfileEntity?> myProfile(Ref ref) async {
  final notifier = ref.watch(myProfileNotifierProvider);
  return notifier.when(
    data: (profile) => profile,
    loading: () => null,
    error: (error, stack) => null,
  );
}

@riverpod
Future<ProfileEntity?> userProfile(Ref ref, String userId) async {
  final notifier = ref.watch(userProfileNotifierProvider(userId));
  return notifier.when(
    data: (profile) => profile,
    loading: () => null,
    error: (error, stack) => null,
  );
}
