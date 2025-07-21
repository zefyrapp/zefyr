
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/profile/domain/entities/profile_entity.dart';
import 'package:zefyr/features/profile/presentation/view_model/edit_profile_state.dart';
import 'package:zefyr/features/profile/providers/profile_providers.dart';

part 'edit_profile_view_model.g.dart';

@riverpod
class EditProfileViewModel extends _$EditProfileViewModel {
  late final ProfileEntity _original;
  @override
  EditProfileState build(ProfileEntity profile) {
    _original = profile;
    ref.keepAlive();
    return EditProfileState(
      name: profile.name,
      nickname: profile.nickname,
      bio: profile.bio,
      avatarUrl: profile.avatar,
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

  /// Обновляет аватар
  void updateAvatar(String? avatar) {
    state = state.copyWith(avatar: avatar);
  }

  /// Проверяет, есть ли изменения
  bool get hasChanges =>
      state.name != _original.name ||
      state.nickname != _original.nickname ||
      state.bio != _original.bio ||
      state.avatar != _original.avatar;

  /// Сохраняет изменения профиля
  Future<bool> saveProfile() async {
    if (!hasChanges) return false;

    if (!_validateFields()) {
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final myProfileNotifier = ref.read(myProfileNotifierProvider.notifier);
      await myProfileNotifier.updateProfile(
        name: state.name!,
        nickname: state.nickname!,
        bio: state.bio!,
        avatar: state.avatar,
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

  Future<void> selectPick() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      state = state.copyWith(avatar: image.path);
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
      final newNickname = '@${state.nickname!.trim()}';
      state = state.copyWith(nickname: newNickname);
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
    state = state.copyWith();
  }
}
