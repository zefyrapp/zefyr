import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/core/network/dio_client.dart';
import 'package:zefyr/features/profile/data/datasources/remote_edit_profile_data_source.dart';
import 'package:zefyr/features/profile/data/repositories/edit_profile_repository.dart';
import 'package:zefyr/features/profile/domain/repositories/edit_profile_repository.dart';
import 'package:zefyr/features/profile/usecases/edit_profile.dart';

part 'profile_providers.g.dart';

@riverpod
RemoteEditProfileDataSource remoteEditProfileDataSource(Ref ref) =>
    RemoteEditProfileDataSourceImpl(ref.watch(dioClientProvider));
// DataSources
@riverpod
EditProfileRepository editProfileRepository(Ref ref) =>
    EditProfileRepositoryImpl(ref.watch(remoteEditProfileDataSourceProvider));

// Repository
@riverpod
EditProfileRepository editProfileRepositoryProvider(Ref ref) =>
    EditProfileRepositoryImpl(ref.watch(remoteEditProfileDataSourceProvider));

// Use Cases
@riverpod
EditProfile editProfile(Ref ref) =>
    EditProfile(ref.watch(editProfileRepositoryProvider));

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      final editProfile = ref.watch(editProfileProvider);
      return ProfileViewModel(editProfile: editProfile);
    });

@riverpod
Stream<AuthResponse> profileStateChanges(Ref ref) {
  final editProfile = ref.watch(editProfileProvider);
  return editProfile.stateChanges;
}
