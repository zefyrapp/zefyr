import 'package:zefyr/features/live/data/models/stream_create_request.dart';

/// Состояние формы создания стрима
class StreamFormState {
  const StreamFormState({
    required this.title,
    required this.description,
    required this.previewUrl,
    required this.isValid,
    required this.titleError,
    required this.descriptionError,
    required this.previewUrlError,
  });

  factory StreamFormState.initial() => const StreamFormState(
    title: '',
    description: '',
    previewUrl: '',
    isValid: false,
    titleError: null,
    descriptionError: null,
    previewUrlError: null,
  );

  final String title;
  final String description;
  final String previewUrl;
  final bool isValid;
  final String? titleError;
  final String? descriptionError;
  final String? previewUrlError;

  /// Создает StreamCreateRequest из данных формы
  StreamCreateRequest toRequest() => StreamCreateRequest(
    title: title.trim(),
    description: description.trim(),
    previewUrl: previewUrl.trim(),
  );

  /// Проверяет, можно ли создать стрим
  bool get canCreateStream => isValid && title.trim().isNotEmpty;

  /// Проверяет, есть ли ошибки в форме
  bool get hasErrors =>
      titleError != null || descriptionError != null || previewUrlError != null;

  StreamFormState copyWith({
    String? title,
    String? description,
    String? previewUrl,
    bool? isValid,
    String? titleError,
    String? descriptionError,
    String? previewUrlError,
  }) => StreamFormState(
    title: title ?? this.title,
    description: description ?? this.description,
    previewUrl: previewUrl ?? this.previewUrl,
    isValid: isValid ?? this.isValid,
    titleError: titleError ?? this.titleError,
    descriptionError: descriptionError ?? this.descriptionError,
    previewUrlError: previewUrlError ?? this.previewUrlError,
  );

  /// Обновляет состояние формы с валидацией
  StreamFormState updateWithValidation({
    String? title,
    String? description,
    String? previewUrl,
  }) {
    final newTitle = title ?? this.title;
    final newDescription = description ?? this.description;
    final newPreviewUrl = previewUrl ?? this.previewUrl;

    // Валидация заголовка
    String? titleError;
    if (newTitle.trim().isEmpty) {
      titleError = 'Заголовок обязателен';
    } else if (newTitle.trim().length > 100) {
      titleError = 'Заголовок не может быть длиннее 100 символов';
    }

    // Валидация описания
    String? descriptionError;
    if (newDescription.trim().length > 200) {
      descriptionError = 'Описание не может быть длиннее 200 символов';
    }

    // Валидация URL превью
    String? previewUrlError;
    if (newPreviewUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(newPreviewUrl.trim());
      if (uri == null || !uri.hasScheme) {
        previewUrlError = 'Введите корректный URL';
      }
    }

    // Проверка общей валидности
    final isValid =
        titleError == null &&
        descriptionError == null &&
        previewUrlError == null &&
        newTitle.trim().isNotEmpty;

    return StreamFormState(
      title: newTitle,
      description: newDescription,
      previewUrl: newPreviewUrl,
      isValid: isValid,
      titleError: titleError,
      descriptionError: descriptionError,
      previewUrlError: previewUrlError,
    );
  }

  @override
  String toString() =>
      'StreamFormState(title: $title, description: $description, previewUrl: $previewUrl, isValid: $isValid, titleError: $titleError, descriptionError: $descriptionError, previewUrlError: $previewUrlError)';

  @override
  bool operator ==(covariant StreamFormState other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.description == description &&
        other.previewUrl == previewUrl &&
        other.isValid == isValid &&
        other.titleError == titleError &&
        other.descriptionError == descriptionError &&
        other.previewUrlError == previewUrlError;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      previewUrl.hashCode ^
      isValid.hashCode ^
      titleError.hashCode ^
      descriptionError.hashCode ^
      previewUrlError.hashCode;
}
