import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/presentation/view_model/edit_profile_state.dart';

part 'edit_profile_view_model.g.dart';

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  @override
  EditProfileState build(EditProfileRequest request) {
    ref.onDispose(() {});
    return EditProfileState(
      name: request.name,
      nickname: request.nickname,
      bio: request.bio,
    );
  }

  /// Обновляет значение имени
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// Обновляет значение никнейма
  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname);
  }

  /// Обновляет значение биографии
  void updateBio(String bio) {
    state = state.copyWith(bio: bio);
  }
}
