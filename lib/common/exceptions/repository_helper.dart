import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/exceptions.dart';
import 'package:zefyr/core/error/failures.dart';

class RepositoryHelper {
  /// Выполняет операцию и обрабатывает исключения
  static Future<Either<Failure, T>> safeCall<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e as AppException));
    }
  }

  /// Выполняет операцию с дополнительными действиями после успеха
  static Future<Either<Failure, T>> safeCallWithCallback<T>(
    Future<T> Function() operation,
    Future<void> Function(T result) onSuccess,
  ) async {
    try {
      final result = await operation();
      await onSuccess(result);
      return Right(result);
    } catch (e) {
      return Left(FailureMapper.mapExceptionToFailure(e as AppException));
    }
  }

  /// Выполняет операцию с валидацией до выполнения
  static Future<Either<Failure, T>> safeCallWithValidation<T>(
    Future<T> Function() operation,
    Either<Failure, void> Function() validator,
  ) async {
    final validationResult = validator();
    if (validationResult.isLeft()) {
      return Left(
        validationResult.fold(
          (failure) => failure,
          (_) => throw UnimplementedError(),
        ),
      );
    }

    return safeCall(operation);
  }

  /// Выполняет операцию с предварительной проверкой условия
  static Future<Either<Failure, T>> safeCallWithCondition<T>(
    Future<T> Function() operation,
    bool condition,
    Failure failureIfConditionFalse,
  ) async {
    if (!condition) {
      return Left(failureIfConditionFalse);
    }
    return safeCall(operation);
  }
}
