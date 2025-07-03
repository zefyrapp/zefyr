import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zefyr/features/live/presentation/view_model/stream_form_state.dart';

/// Провайдер для управления состоянием формы создания стрима
class StreamFormNotifier extends StateNotifier<StreamFormState> {
  StreamFormNotifier() : super(StreamFormState.initial());

  /// Обновляет заголовок стрима
  void updateTitle(String title) {
    state = state.updateWithValidation(title: title);
  }

  /// Обновляет описание стрима
  void updateDescription(String description) {
    state = state.updateWithValidation(description: description);
  }

  /// Обновляет URL превью
  void updatePreviewUrl(String previewUrl) {
    state = state.updateWithValidation(previewUrl: previewUrl);
  }

  /// Обновляет все поля одновременно
  void updateAll({String? title, String? description, String? previewUrl}) {
    state = state.updateWithValidation(
      title: title,
      description: description,
      previewUrl: previewUrl,
    );
  }

  /// Валидирует форму
  bool validateForm() {
    // Принудительно обновляем состояние с текущими значениями для валидации
    state = state.updateWithValidation(
      title: state.title,
      description: state.description,
      previewUrl: state.previewUrl,
    );

    return state.isValid;
  }

  /// Сбрасывает форму в начальное состояние
  void reset() {
    state = StreamFormState.initial();
  }

  /// Устанавливает ошибки полей
  void setFieldErrors({
    String? titleError,
    String? descriptionError,
    String? previewUrlError,
  }) {
    state = state.copyWith(
      titleError: titleError,
      descriptionError: descriptionError,
      previewUrlError: previewUrlError,
      isValid:
          titleError == null &&
          descriptionError == null &&
          previewUrlError == null &&
          state.title.trim().isNotEmpty,
    );
  }
}
