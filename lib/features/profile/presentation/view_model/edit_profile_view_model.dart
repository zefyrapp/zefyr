import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/profile/data/models/edit_profile_request.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/presentation/view_model/edit_profile_state.dart';
import 'package:zefyr/features/profile/providers/profile_providers.dart';

part 'edit_profile_view_model.g.dart';

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  @override
  EditProfileState build(ProfileEntity profile) {
    ref.onDispose(() {});
    return EditProfileState(
      name: profile.name,
      nickname: profile.nickname,
      bio: profile.bio,
      avatar: profile.avatar,
    );
  }

  /// Обновляет значение имени
  void updateName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
  }

  /// Обновляет значение никнейма
  void updateNickname(String nickname) {
    state = state.copyWith(nickname: nickname, errorMessage: null);
  }

  /// Обновляет значение биографии
  void updateBio(String bio) {
    state = state.copyWith(bio: bio, errorMessage: null);
  }

  /// Обновляет аватар
  void updateAvatar(String? avatar) {
    state = state.copyWith(avatar: avatar, errorMessage: null);
  }

  /// Проверяет, есть ли изменения
  bool get hasChanges {
    final original = ref.read(
      editProfileViewModelProvider(ref.read(myProfileNotifierProvider).value!),
    );
    return state.name != original.name ||
        state.nickname != original.nickname ||
        state.bio != original.bio ||
        state.avatar != original.avatar;
  }

  /// Сохраняет изменения профиля
  Future<bool> saveProfile() async {
    if (!hasChanges) return false;

    if (!_validateFields()) {
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final myProfileNotifier = ref.read(myProfileNotifierProvider.notifier);
      await myProfileNotifier.updateProfile(
        name: state.name!,
        nickname: state.nickname!,
        bio: state.bio!,
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Валидация полей
  bool _validateFields() {
    if (state.name == null || state.name!.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Имя не может быть пустым');
      return false;
    }

    if (state.nickname == null || state.nickname!.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Никнейм не может быть пустым');
      return false;
    }

    if (!state.nickname!.startsWith('@')) {
      state = state.copyWith(errorMessage: 'Никнейм должен начинаться с @');
      return false;
    }

    if (state.nickname!.length < 2) {
      state = state.copyWith(errorMessage: 'Никнейм слишком короткий');
      return false;
    }

    return true;
  }

  /// Получает сообщение об ошибке
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('already exists')) {
      return 'Пользователь с таким именем уже существует';
    }
    if (error.toString().contains('invalid nickname')) {
      return 'Недопустимый никнейм';
    }
    return 'Произошла ошибка при сохранении профиля';
  }

  /// Сброс ошибки
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
