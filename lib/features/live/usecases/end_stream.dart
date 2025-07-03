import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/live/domain/entities/repositories/stream_repository.dart';

class EndStream extends UseCase<void, String>
    with UseCaseLogging<void, String> {
  EndStream(this.repository);
  final StreamRepository repository;

  @override
  Future<Either<Failure, void>> executeUseCase(String params) =>
      repository.stopStream(params);
}
