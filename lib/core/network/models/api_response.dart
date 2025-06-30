/// Базовая модель ответа от API
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  /// Создание успешного ответа
  factory ApiResponse.success(T data, [String message = 'Success']) =>
      ApiResponse<T>(
        success: true,
        message: message,
        data: data,
      ); // Может быть Map<String, dynamic>, String, List и т.д.

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    final dynamic dataJson = json['data'];
    T? parsedData;

    if (dataJson != null && fromJsonT != null) {
      if (dataJson is Map<String, dynamic>) {
        parsedData = fromJsonT(dataJson);
      } else if (dataJson is List && dataJson.isNotEmpty) {
        // Если data - это список, но мы ожидаем один объект
        final firstItem = dataJson.first;
        if (firstItem is Map<String, dynamic>) {
          parsedData = fromJsonT(firstItem);
        }
      }
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parsedData,
      errors: json['errors'], // Оставляем как есть - может быть любой тип
    );
  }

  /// Создание ответа с ошибкой
  factory ApiResponse.error(String message, [dynamic errors]) =>
      ApiResponse<T>(success: false, message: message, errors: errors);

  final bool success;
  final String message;
  final T? data;
  final dynamic errors;

  /// Проверка успешности ответа
  bool get isSuccess => success;

  /// Проверка наличия ошибок
  bool get hasErrors => errors != null;

  /// Получение ошибок как [Map<String, List<String>>] (для валидации)
  Map<String, List<String>>? get validationErrors {
    if (errors is Map<String, dynamic>) {
      final Map<String, List<String>> result = {};
      final errorsMap = errors as Map<String, dynamic>;

      for (final entry in errorsMap.entries) {
        if (entry.value is List) {
          result[entry.key] = (entry.value as List).cast<String>();
        } else if (entry.value is String) {
          result[entry.key] = [entry.value as String];
        }
      }
      return result.isEmpty ? null : result;
    }
    return null;
  }

  /// Получение первой ошибки валидации
  String? get firstValidationError {
    final validation = validationErrors;
    if (validation != null && validation.isNotEmpty) {
      final firstKey = validation.keys.first;
      final firstErrors = validation[firstKey];
      return firstErrors?.isNotEmpty ?? false ? firstErrors!.first : null;
    }
    return null;
  }

  /// Получение ошибок как строки
  String? get errorsAsString {
    if (errors == null) return null;

    if (errors is String) {
      return errors as String;
    }

    if (errors is Map<String, dynamic>) {
      final validation = validationErrors;
      if (validation != null) {
        return validation.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
      }
    }

    return errors.toString();
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
}

/// Модель ответа для списков
class ApiListResponse<T> {
  const ApiListResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });
  // Для пагинации и мета-информации

  factory ApiListResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJsonT,
  }) {
    final dynamic dataJson = json['data'];
    List<T>? parsedData;

    if (dataJson != null && fromJsonT != null) {
      if (dataJson is List) {
        parsedData = dataJson
            .whereType<Map<String, dynamic>>()
            .map(fromJsonT)
            .toList();
      }
    }

    return ApiListResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parsedData,
      errors: json['errors'],
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  final bool success;
  final String message;
  final List<T>? data;
  final dynamic errors;
  final Map<String, dynamic>? meta;

  bool get isSuccess => success;
  bool get hasErrors => errors != null;
  bool get hasData => data != null && data!.isNotEmpty;
}
