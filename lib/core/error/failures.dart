import 'package:equatable/equatable.dart';
import 'package:zefyr/core/error/exceptions.dart';

/// Абстрактный базовый класс для всех ошибок
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code, this.data});
  final String message;
  final String? code;
  final dynamic data;

  @override
  List<Object?> get props => [message, code, data];

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Ошибки сервера
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Ошибка сервера. Попробуйте позже.',
    super.code,
    super.data,
  });
}

/// Ошибки кеша
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Ошибка загрузки данных из кеша.',
    super.code,
    super.data,
  });
}

/// Ошибки сети
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Проверьте подключение к интернету.',
    super.code,
    super.data,
  });
}

/// Ошибки валидации
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Проверьте правильность введенных данных.',
    super.code,
    super.data,
  });
}

/// Ошибки авторизации
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Ошибка авторизации.',
    super.code,
    super.data,
  });
}

/// Ошибки разрешений
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Недостаточно прав доступа.',
    super.code,
    super.data,
  });
}

/// Ошибки таймаута
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Превышено время ожидания.',
    super.code,
    super.data,
  });
}

/// Ошибки форматирования данных
class FormatFailure extends Failure {
  const FormatFailure({
    super.message = 'Ошибка обработки данных.',
    super.code,
    super.data,
  });
}

/// Ошибки не найденного ресурса
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Запрашиваемый ресурс не найден.',
    super.code,
    super.data,
  });
}

/// Ошибки конфликта данных
class ConflictFailure extends Failure {
  const ConflictFailure({
    super.message = 'Конфликт данных.',
    super.code,
    super.data,
  });
}

/// Ошибки превышения лимита
class LimitExceededFailure extends Failure {
  const LimitExceededFailure({
    super.message = 'Превышен лимит запросов.',
    super.code,
    super.data,
  });
}

/// Ошибки недоступности сервиса
class ServiceUnavailableFailure extends Failure {
  const ServiceUnavailableFailure({
    super.message = 'Сервис временно недоступен.',
    super.code,
    super.data,
  });
}

/// Общие ошибки приложения
class GeneralFailure extends Failure {
  const GeneralFailure({
    super.message = 'Произошла непредвиденная ошибка.',
    super.code,
    super.data,
  });
}

/// Утилита для преобразования исключений в ошибки
class FailureMapper {
  static Failure mapExceptionToFailure(
    AppException exception,
  ) => switch (exception.runtimeType) {
    const (ServerException) => ServerFailure(message: exception.message),
    const (NetworkException) => NetworkFailure(message: exception.message),
    const (CacheException) => CacheFailure(message: exception.message),
    const (ValidationException) => ValidationFailure(
      message: exception.message,
    ),
    const (AuthException) => AuthFailure(message: exception.message),
    const (PermissionException) => PermissionFailure(
      message: exception.message,
    ),
    const (TimeoutException) => TimeoutFailure(message: exception.message),
    const (FormatException) => FormatFailure(message: exception.message),
    const (NotFoundException) => NotFoundFailure(message: exception.message),
    const (ConflictException) => ConflictFailure(message: exception.message),
    const (LimitExceededException) => LimitExceededFailure(
      message: exception.message,
    ),
    const (ServiceUnavailableException) => ServiceUnavailableFailure(
      message: exception.message,
    ),
    _ => GeneralFailure(message: exception.message),
  };
}
