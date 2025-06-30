/// Базовый класс для всех исключений в приложении
abstract class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Исключения связанные с сервером
class ServerException extends AppException {
  const ServerException(super.message);
}

/// Исключения связанные с кешем
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Исключения связанные с сетью
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Исключения валидации
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Исключения авторизации
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Исключения разрешений
class PermissionException extends AppException {
  const PermissionException(super.message);
}

/// Исключения таймаута
class TimeoutException extends AppException {
  const TimeoutException(super.message);
}

/// Исключения форматирования данных
class FormatException extends AppException {
  const FormatException(super.message);
}

/// Исключения не найденного ресурса
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

/// Исключения конфликта данных
class ConflictException extends AppException {
  const ConflictException(super.message);
}

/// Исключения превышения лимита
class LimitExceededException extends AppException {
  const LimitExceededException(super.message);
}

/// Исключения недоступности сервиса
class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException(super.message);
}
