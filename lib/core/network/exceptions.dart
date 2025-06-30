import 'package:zefyr/core/error/exceptions.dart';

/// Исключение для неуспешных API ответов
class ApiResponseException extends AppException {
  const ApiResponseException(super.message, {this.errors, this.statusCode});

  final dynamic errors;
  final int? statusCode;

  @override
  String toString() {
    final buffer = StringBuffer('ApiResponseException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (errors != null) {
      buffer.write('\nErrors: $errors');
    }
    return buffer.toString();
  }
}
