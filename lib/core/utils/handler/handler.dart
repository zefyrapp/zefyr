import 'package:zefyr/core/error/exceptions.dart';

sealed class Handler {
  const Handler();
  static Future<T> handle<T>(Future<T> Function() f) async {
    try {
      return f.call();
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Обработка исключений для конкретного контекста
  static Exception _handleException(dynamic e) {
    if (e is AppException) {
      return e;
    }
    return ServerException(e.toString());
  }
}
