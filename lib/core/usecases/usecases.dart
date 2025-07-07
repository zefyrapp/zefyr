import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:zefyr/core/error/failures.dart';

/// Базовый абстрактный класс для всех Use Cases
abstract class UseCase<Type, Params> {
  /// Выполняет use case с заданными параметрами
  Future<Either<Failure, Type>> call(Params params);
}

/// Use Case без параметров
abstract class UseCaseNoParams<Type> {
  /// Выполняет use case без параметров
  Future<Either<Failure, Type>> call();
}

/// Синхронный Use Case
abstract class UseCaseSync<Type, Params> {
  /// Синхронно выполняет use case с заданными параметрами
  Either<Failure, Type> call(Params params);
}

/// Синхронный Use Case без параметров
abstract class UseCaseSyncNoParams<Type> {
  /// Синхронно выполняет use case без параметров
  Either<Failure, Type> call();
}

/// Stream Use Case
abstract class StreamUseCase<Type, Params> {
  /// Возвращает поток данных для use case
  Stream<Either<Failure, Type>> call(Params params);
}

/// Stream Use Case без параметров
abstract class StreamUseCaseNoParams<Type> {
  /// Возвращает поток данных для use case без параметров
  Stream<Either<Failure, Type>> call();
}

/// Класс для случаев когда параметры не нужны
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

/// Базовый класс для параметров Use Case
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

/// Утилиты для работы с Use Cases
class UseCaseUtils {
  /// Выполняет несколько use cases параллельно
  static Future<Either<Failure, List<T>>> executeParallel<T>(
    List<Future<Either<Failure, T>>> useCases,
  ) async {
    try {
      final results = await Future.wait(useCases);
      final failures = <Failure>[];
      final successes = <T>[];

      for (final result in results) {
        result.fold(
          (failure) => failures.add(failure),
          (success) => successes.add(success),
        );
      }

      if (failures.isNotEmpty) {
        return Left(failures.first);
      }

      return Right(successes);
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  /// Выполняет use cases последовательно
  static Future<Either<Failure, List<T>>> executeSequential<T>(
    List<Future<Either<Failure, T>> Function()> useCaseFactories,
  ) async {
    final results = <T>[];

    for (final factory in useCaseFactories) {
      final result = await factory();

      final failure = result.fold((failure) => failure, (success) {
        results.add(success);
        return null;
      });

      if (failure != null) {
        return Left(failure);
      }
    }

    return Right(results);
  }

  /// Повторяет выполнение use case при неудаче
  static Future<Either<Failure, T>> retry<T>(
    Future<Either<Failure, T>> Function() useCase, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Failure)? shouldRetry,
  }) async {
    Either<Failure, T>? lastResult;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      lastResult = await useCase();

      final shouldContinue = lastResult.fold((failure) {
        if (attempt == maxRetries) return false;
        return shouldRetry?.call(failure) ?? true;
      }, (_) => false);

      if (!shouldContinue) break;

      if (attempt < maxRetries) {
        await Future<void>.delayed(delay);
      }
    }

    return lastResult!;
  }

  /// Выполняет use case с таймаутом
  static Future<Either<Failure, T>> withTimeout<T>(
    Future<Either<Failure, T>> useCase, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await useCase.timeout(timeout);
    } catch (e) {
      return Left(TimeoutFailure(message: 'Use case timed out: $e'));
    }
  }
}

/// Миксин для логирования Use Cases
mixin UseCaseLogging<Type, Params> on UseCase<Type, Params> {
  String get useCaseName => runtimeType.toString();

  @override
  Future<Either<Failure, Type>> call(Params params) async {
    log('🚀 Executing $useCaseName with params: $params');
    final stopwatch = Stopwatch()..start();

    final result = await executeUseCase(params);

    stopwatch.stop();

    result.fold(
      (failure) => log(
        '❌ $useCaseName failed: ${failure.message} (${stopwatch.elapsedMilliseconds}ms)',
      ),
      (success) =>
          log('✅ $useCaseName succeeded (${stopwatch.elapsedMilliseconds}ms)'),
    );

    return result;
  }

  /// Метод для выполнения основной логики use case
  Future<Either<Failure, Type>> executeUseCase(Params params);
}

/// Пример использования миксина
/*
class LoginUser extends UseCase<User, LoginParams> with UseCaseLogging<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, User>> executeUseCase(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}
*/
