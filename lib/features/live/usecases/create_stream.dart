import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/live/data/models/stream_create_request.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';
import 'package:zefyr/features/live/domain/entities/repositories/stream_repository.dart';

class CreateStream extends UseCase<StreamCreateResponse, StreamCreateRequest>
    with UseCaseLogging<StreamCreateResponse, StreamCreateRequest> {
  CreateStream(this.repository);
  final StreamRepository repository;

  @override
  Future<Either<Failure, StreamCreateResponse>> executeUseCase(
    StreamCreateRequest params,
  ) => repository.createStream(params);
}
