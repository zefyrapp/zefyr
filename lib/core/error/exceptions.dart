/// Базовый класс для всех исключений в приложении
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Исключения связанные с сервером
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// Исключения связанные с кешем
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred']);
}

/// Исключения связанные с сетью
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

/// Исключения валидации
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation error occurred']);
}

/// Исключения авторизации
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error occurred']);
}

/// Исключения разрешений
class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied']);
}

/// Исключения таймаута
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timeout']);
}

/// Исключения форматирования данных
class FormatException extends AppException {
  const FormatException([super.message = 'Data format error']);
}

/// Исключения не найденного ресурса
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Исключения конфликта данных
class ConflictException extends AppException {
  const ConflictException([super.message = 'Data conflict occurred']);
}

/// Исключения превышения лимита
class LimitExceededException extends AppException {
  const LimitExceededException([super.message = 'Limit exceeded']);
}

/// Исключения недоступности сервиса
class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException([super.message = 'Service unavailable']);
}
