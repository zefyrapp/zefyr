import 'package:dartz/dartz.dart';
import 'package:zefyr/core/error/failures.dart';
import 'package:zefyr/core/usecases/usecases.dart';
import 'package:zefyr/features/home/domain/repositories/home_stream_repository.dart';
import 'package:zefyr/features/live/data/models/stream_create_response.dart';

class GetStreams extends UseCase<StreamCreateResponse, StreamPageParams>
    with UseCaseLogging<StreamCreateResponse, StreamPageParams> {
  GetStreams(this.repository);
  final HomeStreamRepository repository;

  @override
  Future<Either<Failure, StreamCreateResponse>> executeUseCase(
    StreamPageParams params,
  ) => repository.getStreams(page: params.page, pageSize: params.pageSize);
}

class StreamPageParams {
  const StreamPageParams({required this.page, required this.pageSize});

  final int page;
  final int pageSize;
}
